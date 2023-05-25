# Database Functions

## Trigger Functions

### new_member_from_user

Creates a `member`, personal `account` and links member to their personal account in `member_account` for each new `supertokens.all_auth_recipe_users` record.

## Standard Functions

### ACCOUNTS

#### get_member_accounts(member_uid)

Returns accounts for the authed member. in V1.0 an premium account will get created the first time a member access a premium feature. This means there will normally be one personal account, and one premium account per active member. 

### ORGANIZATIONS

#### create_org_w_logbook(member_uid, account_uid)

Creates a new org, with logbook, in the account, if the member has permissions.

#### get_org(member_uid, org_uid)

Gets org info, if the member has permissions.

#### update_org(member_uid, org_uid, org_data)

Update org info, if the member has permissions.

#### delete_org(member_uid, org_uid)

Delete org info, if the member has permissions.

### LOGBOOK

#### get_logbook_entries(member_uid, logbook_uid)

Gets paginated logbook entries, most recent first.

#### create_logbook_entry(member_uid, logbook_uid, note, event_time, nugget_uid)

Create a logbook entry, this is done automatically by most platform actions as needed.

### GROUPS

#### get_org_groups(member_uid, org_uid)

#### get_group(member_uid, group_uid)

#### update_group(member_uid, group_uid, group_data)

#### delete_group(member_uid, group_uid)

### GROUP MEMBERS

#### add_group_member(member_uid, group_uid, member_info)

#### get_group_member(member_uid, group_member_uid)

#### update_group_member_member_uid, group_member_uid, group_data)

#### delete_group_member(member_uid, group_member_uid)

### NUGGETS

#### get_nuggets_by_type(member_uid, org_uid, nugget_type)

#### get_nugget(member_uid, nugget_uid)

#### add_nugget(member_uid, org_uid, nugget_data)

#### update_nugget(member_uid, nugget_uid, nugget_data)

#### delete_nugget(member_uid, nugget_uid)

### COMMENTS

#### get_comments_by_nugget(member_uid, nugget_uid)

#### create_comment_for_nugget(member_uid, nugget_uid, comment_data)

#### update_comment(member_uid, comment_uid, comment_data)

#### delete_comment(member_uid, comment_uid)

### REPLIES

#### get_replies_by_comment(member_uid, comment_uid)

#### create_replies_for_comment(member_uid, comment_uid, reply_uid, reply_data)

#### update_replies_for_comment(member_uid, comment_uid, reply_uid, reply_data)

#### delete_comment(member_uid, reply_uid)

### REACTIONS

#### get_reactions_by_nugget(member_uid, nugget_uid)

#### create_reaction_for_nugget(member_uid, nugget_uid, reaction_data)

#### update_reaction(member_uid, reaction_uid, reaction_data)

#### delete_comment(member_uid, reaction_uid)






