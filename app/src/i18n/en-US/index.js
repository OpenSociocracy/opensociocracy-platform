import account from './account';
import apps from './apps';
import auth from './auth';
import homepage from './homepage';
import member from './member';
import nav from './nav';
import notifications from './notifications';
import tos from './tos';

export default {
  ...account,
  ...apps,
  ...auth,
  ...homepage,
  ...member,
  ...nav,
  ...notifications,
  ...tos
};
