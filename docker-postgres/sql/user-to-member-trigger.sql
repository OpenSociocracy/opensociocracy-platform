GRANT USAGE ON SCHEMA opensociocracy_api TO opensociocracy_supertokens;
GRANT ALL ON ALL SEQUENCES IN SCHEMA opensociocracy_api TO opensociocracy_supertokens;
GRANT ALL ON ALL TABLES IN SCHEMA opensociocracy_api TO opensociocracy_supertokens;
CREATE OR REPLACE TRIGGER new_user_member_account AFTER INSERT ON supertokens.all_auth_recipe_users FOR EACH ROW EXECUTE FUNCTION opensociocracy_api.new_member_from_user();