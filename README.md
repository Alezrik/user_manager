# UserManager

[![Build Status](https://travis-ci.org/Alezrik/user_manager.svg?branch=master)](https://travis-ci.org/Alezrik/user_manager)

**A module for managing Users with Authentication and Authorization**

This module is a collection of GenStage work-flows for managing Users and User Accounts.


## Installation

This is currently not deployed in hex

```elixir
def deps do
  [{:user_manager, git: "https://github.com/Alezrik/user_manager.git"}]
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

## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/user_manager](https://hexdocs.pm/user_manager).

## Blog
https://excavationofimagination.wordpress.com/
