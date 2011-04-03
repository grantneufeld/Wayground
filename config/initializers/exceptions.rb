module Wayground
  # attempt to authenticate with an Authentication assigned to a different user
  class WrongUserForAuthentication < Exception; end
  # attempt to assign the "global" authority area to a model
  class ModelAuthorityAreaCannotBeGlobal < Exception; end
end
