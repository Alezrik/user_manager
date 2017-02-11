# UserManager

[![Build Status](https://travis-ci.org/Alezrik/user_manager.svg?branch=master)](https://travis-ci.org/Alezrik/user_manager)
[![Coverage Status](https://coveralls.io/repos/github/Alezrik/user_manager/badge.svg?branch=master)](https://coveralls.io/github/Alezrik/user_manager?branch=master)
[![Ebert](https://ebertapp.io/github/Alezrik/user_manager.svg)](https://ebertapp.io/github/Alezrik/user_manager)

**A module for managing Users with Authentication and Authorization**

This module is a collection of GenStage work-flows for managing Users and User Accounts.


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
