#!/usr/bin/env bash
set -euo pipefail
: "${BASE_URL:?}" "${ADMIN_USERNAME:?}" "${ADMIN_PASSWORD:?}"
# The shell entry point owns the disposable API target; Python only handles JSON.
python3 - <<'PY'
import json, os, urllib.request, urllib.error
base=os.environ['BASE_URL']
def call(method,path,body=None,token=None,expected=None):
    headers={'Content-Type':'application/json'}
    if token: headers['Authorization']='Bearer '+token
    req=urllib.request.Request(base+path, None if body is None else json.dumps(body).encode(),headers,method=method)
    try:
        with urllib.request.urlopen(req,timeout=30) as r: return json.load(r).get('data')
    except urllib.error.HTTPError as e:
        if expected and e.code==expected: return None
        raise RuntimeError(f'{method} {path} failed with status {e.code}') from None
call('GET','/budget?period=2026-08',expected=401)
token=call('POST','/open/auth/login',{'username':os.environ['ADMIN_USERNAME'],'password':os.environ['ADMIN_PASSWORD']})['access_token']
profile={'nickname':'Budget Admin','gender':'others','phone_number':'+65 6123 4567','location':'Singapore','birth_date':'1992-08-21'}
call('PUT','/user/profile',profile,token)
p=call('GET','/user/profile',token=token)
assert all(p[k]==v for k,v in profile.items())
configuration={'display_language':'zh-Hans','currency_code':'SGD','active_theme_color':'#008080'}
call('PUT','/user/configuration',configuration,token)
p=call('GET','/user/configuration',token=token)
assert all(p[k]==v for k,v in configuration.items())
category=call('POST','/category',{'name':'Budget Smoke','type':'expense','remark':'disposable budget smoke'},token)
cid=category.get('id',category.get('Id'))
budget={'category_id':cid,'period':'2026-08','limit_amount':500}
bid=call('POST','/budget',budget,token)['id']
call('POST','/cash/expense',{'belongs_date':'20260821','category_name':'Budget Smoke','amount':125.5,'description':'Budget smoke expense'},token)
def items():
    data=call('GET','/budget?period=2026-08',token=token)
    if isinstance(data,dict): data=data.get('data',data)
    return [x for x in data if x['id']==bid]
assert len(items())==1 and abs(float(items()[0]['spent_amount'])-125.5)<.001
budget['limit_amount']=750
assert float(call('PUT','/budget/'+bid,budget,token)['limit_amount'])==750
call('DELETE','/budget/'+bid,token=token)
assert not items()
print('Budget/profile/configuration acceptance passed.')
PY
