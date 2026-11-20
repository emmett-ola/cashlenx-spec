# App 代码架构

> 本文是 [App Code Architecture](code-architecture.md) 的简体中文译文，供中文阅读者参考。若译文与英文原文存在差异，以英文原文为准。

## 分析基线

- App 版本：`1.1.1+18`。
- 源代码提交：`develop` 分支上的 `a74effdd1d4be826e8158e22820458611bce9d05`。
- 分析范围：`lib/` 下已提交的 App 源代码、声明的依赖以及已提交的测试。未提交的平台和工具链改动不在本次分析范围内。
- 本次分析未执行、修改、构建、测试或部署 Server，也未将 Server 作为主动工作区域。

## 概要

App 采用以功能为中心的 Flutter 目录结构，并使用 Riverpod 完成依赖组装和状态管理。认证模块对 Clean Architecture 的应用最完整；预算和统计模块具有较轻量的仓储层与领域层边界；多个成熟的 UI 流程则集中在由展示层拥有的 Home 库中。因此，当前架构更准确的描述是：**以功能为中心、选择性分层的架构**，而不是统一采用完整 Clean Architecture 的架构。

主要运行时调用路径如下：

```text
Flutter UI
  -> Riverpod Provider 或本地控制器
  -> 功能仓储或直接的功能编排
  -> CashlenxApi
  -> ApiClient / RestClient
  -> Dio + 拦截器
  -> HTTP API
```

Demo 模式采用一条并行的本地调用路径：

```text
Flutter UI
  -> Riverpod Provider 或功能仓储
  -> DemoDataStore
  -> 内存中的 API 形态数据
```

当前架构在应用组装、路由、会话处理、设计系统和测试基础方面较为完善。主要可维护性约束在于：Home 库和若干功能页面体量较大，同时承担展示、响应映射、状态编排和数据源选择等多种职责。

## 仓库结构

```text
lib/
  main.dart                  # 启动入口和根 ProviderScope。
  core/                      # 全局配置和基础设施契约。
    config/
    i18n/
    infrastructure/
      errors/
      http/
      logging/
      persistence/
      routing/
    network/                 # 共享响应包装结构。
    services/                # 安全会话持久化。
    utils/
  network/                   # Dio 组装、API 适配器、认证拦截器。
  routing/                   # GoRouter 路由和重定向策略集成。
  features/
    auth/                    # 完整的 data/domain/presentation 分层。
    budget/                  # 领域模型、仓储、展示层。
    demo/                    # 内存中的替代数据源。
    home/                    # 已认证应用外壳和财务 UI 库。
    onboarding/             # 本地引导状态和 UI。
    profile/                # Profile 领域模型和展示层编排。
    settings/               # 账户配置同步。
    setup/                   # 首次登录设置状态和 UI。
    splash/                  # 启动展示层。
    statistics/             # 领域模型、仓储、查询上下文和 UI。
  shared/                    # 跨功能格式化器、资源和组件。
  theme/                     # 设计令牌、语义颜色、字体和主题状态。
```

在本次分析基线上，`lib/` 包含 85 个已跟踪的 Dart 文件，其中 12 个是生成的 `*.g.dart` 或 `*.freezed.dart` 文件。已提交的测试包含 37 个 Dart 测试文件，以及浏览器和 Shell 验收测试资源。

## 应用组装

### 启动过程

`lib/main.dart` 是应用的组合根。启动过程按顺序执行以下四步：

1. 初始化 Flutter 绑定。
2. 通过 `AppConfig.init()` 解析编译期运行配置。
3. 在第一帧之前加载仓库内置的区域字体。
4. 在根 `ProviderScope` 内启动 Widget 树。

`CashLenXApp` 监听路由器、主题模式、主题色和语言 Provider，并构建 `MaterialApp.router`。因此，语言、主题和导航变化由 Riverpod 状态触发重组，而不是通过独立的服务定位器完成。

虽然 `get_it` 和 `injectable` 已在依赖中声明，但已提交的运行时代码并未导入它们。当前实际使用的依赖注入方式是 Riverpod。类似地，`fpdart` 和 `equatable` 已声明，但已提交的 `lib/` 代码没有导入它们。

### 路由与访问控制

`lib/routing/app_router.dart` 负责路由注册和全局重定向。重定向决策组合了三个异步状态源：

- 认证状态；
- 是否已完成引导；
- 是否已完成首次登录设置。

纯 Dart 的 `AuthRedirectPolicy` 保存重定向规则，GoRouter 则负责 URL 解析、历史记录和页面创建。受保护路由组件在呈现认证内容前，会再次检查会话和设置完成状态，形成第二层防御。

主要认证后页面使用 `NoTransitionPage`，并通过不同的 `HomeSection` 值复用 `HomePage`。Profile 和交易详情是可通过 URL 直接访问的次级页面。这种方式保证了浏览器刷新和历史记录的一致性，但也使 `HomePage` 成为多个功能界面的中央协调者。

## 分层模型

### 展示层

展示层由 Flutter Widget 和 Riverpod Provider 组成。App 同时使用生成式 Provider（`@riverpod`、`@Riverpod`）以及手动声明的 `Provider`、`FutureProvider` 和 `NotifierProvider`。

当前并存三种状态管理方式：

| 状态类型 | 典型用途 | 示例 |
| --- | --- | --- |
| 全局响应式状态 | 会话和持久化用户偏好 | `AuthNotifier`、`i18nProvider`、`themeColorProvider`、`currencyProvider` |
| 请求状态 | 异步功能数据 | `_dashboardProvider`、`monthlyBudgetsProvider`、`statisticsProvider` |
| Widget 本地状态 | 草稿、筛选条件、导航细节、加载标记 | 交易表单、Profile 编辑、分类编辑器 |

这种组合较为务实：Riverpod 管理跨路由或跨功能的状态，短生命周期的交互状态则保留在对应 Widget 附近。代价是不同功能之间的数据失效和错误处理方式尚不完全一致。

### 领域层

领域代码规模较小，并且不依赖 Flutter：

- Auth 拥有生成式 `User` 模型和 `AuthRepository` 契约。
- Budget 拥有 `BudgetItem` 和 `BudgetCategory`。
- Statistics 拥有 `AnalyticsRange`、`StatisticsSnapshot` 和 `TopExpense`。
- Profile 拥有 `UserProfile`，并复用 Auth 的 `User` 模型作为回退数据。

Budget、Statistics 和 Profile 的领域对象目前会自行解析与传输格式相似的 Map。它们仍是纯 Dart 对象，但没有完全与传输字段名隔离。Auth 是唯一具有独立 DTO 层的功能。

项目没有显式的 Use Case 或 Interactor 层。业务操作由 Riverpod Notifier、仓储、服务和页面控制器共同承担。

### 数据层和基础设施

共享网络栈的分层如下：

```text
CashlenxApi
  -> ApiClient implements RestClient
  -> Dio
     -> RequestTrackingInterceptor
     -> AuthInterceptor
```

- `CashlenxApi` 是 App 专用的接口适配器和请求结构构造层。
- `ApiClient` 提供 HTTP 动词，并将 Dio 异常映射为 App 异常。
- `RestClient` 是 `ApiClient` 实现的传输抽象。
- `AuthInterceptor` 负责附加访问令牌、串行化并发刷新、重试符合条件的请求，并且只使仍然有效的当前会话失效。
- `RequestTrackingInterceptor` 集中处理请求日志。
- `ResponseWrapper<T>` 在使用类型化解码时表示标准响应包装结构。

`AppConfig` 根据编译期的 `APP_ENV`、`API_SCHEME`、`API_DOMAIN`、`API_PORT` 和 `API_VERSION` 定义构建 API 基础 URL。环境文件是运维和构建输入，并不会作为 Flutter 运行时资源加载。

## 功能边界

### 认证：完整分层的功能

认证模块具有最清晰的依赖链：

```text
Auth 页面
  -> AuthNotifier
  -> AuthRepository 接口
  -> AuthRepositoryImpl
  -> AuthRemoteDataSource
  -> CashlenxApi
```

Freezed 和 json_serializable 模型定义请求、响应和用户数据。`AuthRepositoryImpl` 协调安全令牌持久化和远程调用。`SecureStorageService` 依赖 `KeyValueStore` 抽象，因此可以在单元测试中使用内存实现，而无需平台安全存储。

该功能存在一个有意保留的跨功能依赖：用户进入 Demo 模式时，`AuthNotifier` 会重置 `DemoDataStore`。

### Home：应用外壳和集成边界

`HomePage` 负责认证后的应用外壳、底部导航、外壳内的次级页面、Profile 刷新、Dashboard 数据失效以及新增交易面板。其展示代码拆分为以下 Dart `part` 文件：

- `dashboard_tab.part.dart`；
- `category_tab.part.dart`；
- `transactions.part.dart`；
- `settings_tab.part.dart`；
- `shared_widgets.part.dart`；
- `home_models.part.dart`。

这些文件共同构成一个私有 Dart 库。文件拆分缩小了单次编辑范围，但并没有形成真正的模块边界：所有私有模型和辅助函数仍可相互共享，这些 part 文件也无法作为独立库导入或测试。

Home 还直接依赖 Auth、Budget、Demo、Profile、Settings、Statistics、API 适配器、格式化、路由和主题层。因此，它既是 UI 外壳，也是主要的应用集成边界。

### Budget 与 Statistics：轻量仓储型功能

Budget 和 Statistics 都具有纯 Dart 领域模型、功能仓储和展示界面。它们的仓储会在 `CashlenxApi` 与 `DemoDataStore` 之间选择数据源，并将 API 形态数据映射为类型化领域对象。

Statistics 会并发发起汇总、序列和最高支出请求，然后将数据规范化为 `StatisticsSnapshot`。其查询对象实现了值相等性，使 Riverpod Family 缓存具有稳定键值。

这两个功能比 Home 更加隔离，但其数据层 Provider 会直接依赖 Auth 展示层的 Provider，以判断是否处于 Demo 模式。这种跨越功能分层的依赖是当前架构中的一项明显捷径。

### Profile：类型化模型与展示层编排

Profile 拥有领域模型，但没有仓储或数据源层。`ProfilePage` 负责选择在线或 Demo 数据、调用数据源、映射响应、校验草稿，以及管理加载、错误和编辑状态。对于单一页面而言这种实现具有较强内聚性，但也使一个较大的展示文件承担了多种职责。

### Settings、Setup 与 Onboarding

- Settings 将语言、货币、主题色和设置完成状态与账户或 Demo 配置同步，同时保留本地值作为回退。
- Setup 将账户配置与按用户保存的本地完成标记结合。
- Onboarding 使用一个基于 SharedPreferences 的小型服务。

这些功能更接近面向服务的功能切片，而不是完整的 data/domain/presentation 分层。Settings 和 Setup 会导入 Auth、Home、i18n 与 Theme 所拥有的 Provider，因此用户配置状态分散在多个功能和应用级模块中。

### Demo 模式：并行的内存后端

`DemoDataStore` 是一个由 Riverpod 提供的单例内存存储。它使用 API 形态的 Map 实现 Profile、配置、Dashboard、交易、分类、预算和统计行为。`demoDataRevisionProvider` 在数据变更后充当手动失效信号。

这种设计能够在没有认证请求的情况下提供有意义且可编辑的离线演示，并让在线模式与 Demo 模式共享映射逻辑。其代价是结构耦合：Demo 会导入网络层的 `ApiJson` 类型别名，并且必须手动跟随在线 API 的响应结构和业务行为。

## 持久化模型

| 存储方式 | 数据 | 生命周期 |
| --- | --- | --- |
| 安全存储 | 访问令牌、刷新令牌、记住登录标记 | 跨启动 |
| SharedPreferences | 引导状态、按用户设置完成状态、语言、货币、主题色 | 跨启动 |
| 账户配置 API | 语言、货币、主题色、设置完成状态 | 跨设备 |
| Riverpod 内存状态 | 会话状态、异步请求状态、导航上下文 | 当前进程或会话 |
| `DemoDataStore` | Demo 财务、Profile、分类、预算和配置数据 | 当前 Demo 会话 |

当账户配置可用时，App 将其视为权威来源，并保留本地偏好作为离线回退。保存安全会话时，会先持久化轮换后的刷新凭据，再保存访问令牌；若只完成部分写入，则会清除会话。

## 设计系统与本地化

`AppDesignTokens` 集中定义语义颜色、4 px 间距网格、圆角、动效时长和 430 px 移动端画布边界。`AppSurfaceColors` 是一个 `ThemeExtension`，提供语义化的浅色和深色界面颜色。共享 Widget 封装了重复使用的面板、卡片、输入框、按钮、Logo 和响应式外壳。

本地化由 Provider 驱动，目前翻译 Map 保存在 `app_i18n.dart` 中。英文、简体中文和繁体中文使用同一套查询 API。仓库内置的区域 Noto Sans 字体会在第一帧前加载，并根据当前语言选择。

集中式主题和页面外壳是当前架构的优势。单体翻译文件则存在扩展性风险，因为语言数据、语言状态和翻译访问逻辑都位于同一个源文件中。

## 代码生成

Riverpod Generator 生成 Provider 胶水代码，Freezed 和 json_serializable 则生成不可变 Auth 模型与 JSON 编解码代码。生成文件会提交到仓库，但被排除在 Analyzer 输入之外。源文件是唯一的编辑边界，不应手动修改生成的 `*.g.dart` 和 `*.freezed.dart` 文件。

## 测试架构

测试套件按照生产代码结构覆盖核心基础设施、功能、网络、路由、共享 Widget、主题和视觉基线。支持隔离测试的主要接缝包括：

- `KeyValueStore` 的安全存储实现和内存实现；
- 对 Dio 操作进行封装的 `RestClient`；
- `AuthInterceptor` 测试中可注入的 Dio 工厂；
- Riverpod Provider Override；
- 纯函数形式的重定向、格式化和响应规范化逻辑；
- 覆盖手机、最大外壳宽度、平板、桌面、浅色和深色模式的 Golden 测试；
- 覆盖真实账户和 Demo 行为的容器化浏览器流程。

当前设计为基础设施、Auth、Budget 和 Statistics 提供了最强的单元隔离能力。体量较大的 Home 和 Profile 展示文件则更多依赖 Widget 级测试。

## 架构优势

1. Riverpod 提供一致的组合机制，活动代码中不存在隐藏的全局服务定位器。
2. Auth 具有明确的契约、类型化模型、可测试的持久化机制和稳健的轮换令牌并发处理。
3. 路由具备 URL 感知能力，并将纯重定向策略与 GoRouter 接线分离。
4. 领域对象不依赖 Flutter。
5. Demo 模式与认证凭据隔离，并支持有意义且可编辑的完整流程。
6. 设计令牌、语义界面颜色、响应式外壳、本地化和内置字体均已集中管理。
7. 测试覆盖基础设施契约、主要功能行为、路由、对无障碍敏感的 Widget 和视觉回归。

## 耦合与可维护性风险

### 1. Home 是体量较大的共享库

已提交代码中最大的源文件是约 3,073 行的交易 part 文件，以及约 1,286 行的分类 part 文件。由于所有 Home part 文件共享同一个私有库，即使代码已物理拆分，数据模型、API 编排、Widget 和本地状态仍然紧密耦合。

### 2. 分层方式不一致

Auth 使用仓储和数据源抽象，而 Home 与 Profile 会直接调用 `CashlenxApi` 和 `DemoDataStore`。Budget 与 Statistics 位于这两种方式之间。跨功能导入还会从数据模块访问 Auth 的展示状态，并从 Settings 或 Setup 访问 Home 所拥有的货币状态。

### 3. 传输结构向上层泄漏

`ApiJson` Map 和响应包装解包逻辑出现在仓储、展示层拥有的模型、Profile 和 Demo 代码中。这提高了 API 结构变化的成本，也使 Demo 一致性需要人工维护。

### 4. API 适配器范围较大

`CashlenxApi` 约 750 行，包含系统、认证、用户、管理、现金流、分类、预算和统计接口。目前它提供了实用的单一请求契约，但其变更面会随着功能增加而持续扩大。

### 5. 状态所有权较为分散

账户配置横跨 Settings 同步、Home 所拥有的货币状态、core i18n、Theme、Setup、SharedPreferences 和远程配置。相关行为已经实现并经过测试，但尚不存在一个面向领域的配置控制器来统一管理完整生命周期。

### 6. 声明的依赖超出实际架构需求

`get_it`、`injectable`、`fpdart` 和 `equatable` 已声明，但已提交的 `lib/` 代码并未使用。保留未使用的架构类依赖会模糊项目约定，并增加依赖维护成本。

## 建议的演进方向

以下内容是可维护性建议，不代表缺少面向用户的功能。

1. 将 Transactions 和 Categories 从 Home 私有库中提取为独立功能模块，并提供公开的类型化契约。
2. 在继续增加展示行为前，为 Profile、Transactions、Categories 和 Dashboard 引入功能仓储。
3. 使用功能数据源接口替代重复的在线模式与 Demo 模式分支，由 Provider 选择具体实现。
4. 将 API 响应解析移动到数据层 DTO 和 Mapper 中，使领域层与展示层接收类型化对象。
5. 建立一个应用级用户配置控制器，统一拥有本地回退、账户同步、货币、语言、主题和设置完成状态。
6. 将 `CashlenxApi` 拆分为面向功能的客户端，同时保留 `ApiClient` 和共享拦截器。
7. 当翻译目录显著增长时，按语言拆分翻译文件，或采用生成式本地化资源。
8. 移除未使用的依赖，或有意识地正式采用它们；除非通过文档记录的新需求改变了该决策，否则 Riverpod 应继续作为唯一的依赖注入约定。
9. 重构期间保留现有路由、安全会话、设计令牌、无障碍和 Golden 测试边界。

## 建议的依赖方向

新功能或从现有代码中提取出的功能，建议遵循以下方向：

```text
展示层
  -> 应用控制器 / Provider
  -> 领域仓储契约
  <- 数据仓储实现
     -> 远程数据源或 Demo 数据源
        -> 共享网络 / 持久化基础设施
```

框架类型和传输类型应保留在系统边缘。领域模型和仓储契约应保持为纯 Dart，功能之间的访问应通过稳定契约完成，而不是直接依赖另一个功能的展示层 Provider。

## 相关文档

- [App 英文概览](README.md)
- [英文架构原文](code-architecture.md)
- [已实现功能清单](implemented-features.md)
- [系统测试策略](../testing.md)
- [产品范围与流程](../product-and-flows.md)
