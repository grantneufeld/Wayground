module Wayground
  # attempt to access an area/action the user does not have authority for
  class AccessDenied < Exception; end
  # attempt to assign the "global" authority area to a model
  class ModelAuthorityAreaCannotBeGlobal < Exception; end
  # attempt to authenticate with an Authentication assigned to a different user
  class WrongUserForAuthentication < Exception; end
end
