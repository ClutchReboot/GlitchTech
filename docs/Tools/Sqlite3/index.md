---
layout: default
title: {{ site.data.main.name }} | Sqlite3
---

# Tools | Sqlite3
Sqllite3 is full of easy show commands.
The purpose of this document is to track some of them with examples.
Most of these commands can be left blank to provide all information in the database.

## Tables
List names of tables matching LIKE pattern TABLE.
```bash
sqlite> .tables
```

## Schema
Using the `.schema TABLE` command can be useful in finding information on tables.
If you leave it blank, you'll get to see all sorts of information to better tailor your search.
```bash
sqlite> .schema
sqlite> .schema phpbb_acl_groups
CREATE TABLE `phpbb_acl_groups` (
  `group_id` integer  NOT NULL DEFAULT 0
,  `forum_id` integer  NOT NULL DEFAULT 0
,  `auth_option_id` integer  NOT NULL DEFAULT 0
,  `auth_role_id` integer  NOT NULL DEFAULT 0
,  `auth_setting` integer NOT NULL DEFAULT 0
);
```

## Indexes
The `.indexes` command is similar to the `.schema` command.
If left blank, you'll get a list of all the indexes in the database.
You can also view an index associated with a table.
```bash
sqlite> .indexes
sqlite> .indexes phpbb_acl_groups
idx_phpbb_acl_groups_auth_opt_id   idx_phpbb_acl_groups_group_id
idx_phpbb_acl_groups_auth_role_id
```
Sqlite also supports the `LIKE` operator to do partial searches.
```bash
sqlite> .index %es
```
