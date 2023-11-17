# LLDAP Graphql query

URL: /api/graphql/playground

set HTTP HEADER
{ "Authorization": "Bearer token"}

## Get User

```Graphql
{
  user(userId: "admin"){
    id
    attributes {name,value}
    groups{id}
  }
}

```

## updateUserAttribute

```Graphql
mutation { updateUser(
  				user:{
            id:"admin"
            insertAttributes:{
              name:"toto"
            	value:"test"
            }
          }
					){
		  	ok
  }
}
```

## add User attribute

```Graphql

mutation { addUserAttribute(
    name:"toto"
    attributeType:STRING
    isList:true
    isVisible:true
    isEditable:true){
        ok
  }
}
```

## delete user attribute

```graphql
mutation {
  deleteUserAttribute(name: "toto") {
    ok
  }
}
```
