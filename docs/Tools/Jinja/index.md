---
layout: default
title: GlitchTech | Jinja
description: Collection of commonly used tools.
---

# Tools | Jinja
The purpose of this document is to track some commonly used Jinja concepts.

## Objects
Creating and updating an Object / Dictionary is different than python.
Make use of global variables using `set _`. 
### Update
```jinja
{% set data = {} %}
{% set listOfItems = [] %}
{% set _ = data.update({'paramList': listOfItems}) -%}
{{ data['taskInstParamRequestList'] }}
```

## Arrays
Arrays are similar to Objects / Dictionaries, making use of global variables.
### Append
When appending a value to an array, its important to use `or ''` in case that value doesn't exist.
If `or''` was not included and the value does not exist, `None` will be appended to the array.
```jinja
{%- set listOfItems = [] %}
{%- set _ = listOfItems.append('thing') or '' %}
```
### Split
```jinja
{{ response.taskResults[0].TASK_INSTANCE_ID.split('-')[-1] }}
```

### Exists
```jinja
{%- set projectExclusionList = [
    'CM-Monitor Construction',
    'Procurement Financial'
] %}

{%- set tasksAlreadyCreated = initialData.response.taskResults | selectattr('TASK_NAME', 'in', projectExclusionList) | list != [] %}
```


## Gather Data
### Check object key against multiple values
```jinja
{%- set projectExclusionList = [
    'CM-Monitor Construction',
    'Procurement Financial'
] %}

{%- set tasksAlreadyCreated = initialData.response.taskResults | selectattr('TASK_NAME', 'in', projectExclusionList) | list != [] %}
```