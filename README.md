# REST API Client

Library of tools to create REST resource clients (web- и mobile-clients are supported)

## Library structure

The core of library is the `ResourceClient`, which uses `RestClient` to communicate with server. Objects `ResourceClient` is working with must inherit from `Model` class of package `data_model`

`ResourceClient` out of the box supports basic CRUD methods:
* `create` - create object
* `read` - get object/objects from resource
* `update` - update object
* `replace` - replace object
* `delete` - remove object

If you need you can add any other methods while inheritance.

## Example

Usage examples can be found in example directory and in tests

## Testing

`pub run test -p vm,chrome`