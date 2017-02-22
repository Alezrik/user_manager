# UserManager

[![Build Status](https://travis-ci.org/Alezrik/user_manager.svg?branch=master)](https://travis-ci.org/Alezrik/user_manager)
[![Coverage Status](https://coveralls.io/repos/github/Alezrik/user_manager/badge.svg?branch=master)](https://coveralls.io/github/Alezrik/user_manager?branch=master)
[![Ebert](https://ebertapp.io/github/Alezrik/user_manager.svg)](https://ebertapp.io/github/Alezrik/user_manager)
[![Inline docs](http://inch-ci.org/github/Alezrik/user_manager.svg?branch=master)](http://inch-ci.org/github/Alezrik/user_manager)

**A module for managing Users with Authentication and Authorization**

This module is a collection of GenStage work-flows for managing Users and User Accounts.

## Versions
* hex_version: 0.2.0
* git_master_version: 0.3.0

## Installation

https://hex.pm/packages/user_manager/0.2.0

```elixir
def deps do
  [{:user_manager, "~> 0.2.0"}]
end
```

## Environment Variables

<code>
export GUARDIAN_SECRET_KEY="SomeTemporarySuperSecretKeyOnlyIKnow!"

export CIPHER_KEY_PHRASE="testiekeyphraseforcipher"

export CIPHER_IV_PHRASE="testieivphraseforcipher" 

export CIPHER_MAGIC_TOKEN="magictoken" 

export FACEBOOK_APP_SECRET="your app secret"

export FACEBOOK_CLIENT_ID="your app client id"
</code>

## Api Usage

* Create User

UserManager.UserManagerApi.create_user(name, password, email)

* Delete User

UserManager.UserManagerApi.delete_user(user_id)

* Authenticate User

UserManager.UserManagerApi.authenticate_user(name, password, source \\ :browser)

* Identify User

UserManager.UserManagerApi.identify_user(token)

* Authorize User

UserManager.UserManagerApi.authorize_claims(token, permission_list, require_all \\ true) 

* Create Facebook Profile
   * Note: Returns still need to be processed before returning to client, raw json, status_codes etc are in return types

UserManager.UserManagerApi.create_facebook_profile(user_id, facebook_code_token)



## Integrated Components
* Guardian - https://github.com/ueberauth/guardian
  * Token generation / permission handling
* GuardianDb - https://github.com/ueberauth/guardian_db
  * Additional token validation / db serialization of token data
* Comeonin - https://github.com/riverrun/comeonin
  * Validated field encryption with bcrypt
* Facebook - https://github.com/mweibel/facebook.ex
* httpoison - https://github.com/edgurgel/httpoison
* Cipher - https://github.com/rubencaro/cipher

## Scope

goals:
* Agnostic user management for 'any' system needing user management. (phoenix, games)
* Management of user authentication, authorization.
* Management of application user metadata.
* Integration of 3rd party authentication providers

## Documentation

https://hexdocs.pm/user_manager/0.2.0

## Blog
https://excavationofimagination.wordpress.com/
