module Wayground
  # attempt to access an area/action the user does not have authority for
  class AccessDenied < Exception; end
  # attempt to access an area/action that requires the user to be signed in
  class LoginRequired < Exception; end
  # attempt to assign the "global" authority area to a model
  class ModelAuthorityAreaCannotBeGlobal < Exception; end
  # attemtpt to act on a User that is not the same as the source User
  class UserMismatch < Exception; end
  # attempt to assign an authority on a model that does not directly handle authorities
  class WrongModelForSettingAuthority < Exception; end
end
