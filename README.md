# UserManager

[![Build Status](https://travis-ci.org/Alezrik/user_manager.svg?branch=master)](https://travis-ci.org/Alezrik/user_manager)
[![Coverage Status](https://coveralls.io/repos/github/Alezrik/user_manager/badge.svg?branch=master)](https://coveralls.io/github/Alezrik/user_manager?branch=master)
[![Ebert](https://ebertapp.io/github/Alezrik/user_manager.svg)](https://ebertapp.io/github/Alezrik/user_manager)
[![Inline docs](http://inch-ci.org/github/Alezrik/user_manager.svg?branch=master)](http://inch-ci.org/github/Alezrik/user_manager)

**A module for managing Users with Authentication and Authorization**

This module is a collection of GenStage work-flows for managing Users and User Accounts.

## Versions
* hex_version: 0.1.0
* git_master_version: 0.2.0

## Installation

https://hex.pm/packages/user_manager/0.1.0

```elixir
def deps do
  [{:user_manager, "~> 0.1.0"}]
end
```

## Api Usage

* Create User

UserManager.UserManagerApi.create_user(name, password, email)

* Authenticate User

UserManager.UserManagerApi.authenticate_user(name, password, source \\ :browser)

* Identify User

UserManager.UserManagerApi.identify_user(token)

* Authorize User

UserManager.UserManagerApi.authorize_claims(token, permission_list, require_all \\ true) 

## Integrated Components
* Guardian - https://github.com/ueberauth/guardian
  * Token generation / permission handling
* GuardianDb - https://github.com/ueberauth/guardian_db
  * Additional token validation / db serialization of token data
* Comeonin - https://github.com/riverrun/comeonin
  * Validated field encryption with bcrypt

## Scope

goals:
* Agnostic user management for 'any' system needing user management. (phoenix, games)
* Management of user authentication, authorization.
* Management of application user metadata.
* Integration of 3rd party authentication providers

## Documentation

https://hexdocs.pm/user_manager/0.1.0

## Blog
https://excavationofimagination.wordpress.com/
