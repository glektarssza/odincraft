package logging

//-- Core Library
import "core:mem"
import "core:strings"

/*
A type alias for a logging namespace.
*/
Namespace :: string

/*
The string used to separate namespace components.
*/
NAMESPACE_SEPARATOR :: ":"

/*
Create a `Namespace` from an array of namespace components.

### Paramaters ###

* `components` - The namespace components to create a namespace from.
* `allocator` - The memory allocator to use.

### Returns ###

* `result` - The newly created namespace on success; `nil` otherwise.
* `err` - The error on error; `nil` otherwise.
*/
create_namespace_from_components :: proc(
    components: []string,
    allocator: mem.Allocator = context.allocator,
) -> (
    result: Namespace,
    err: mem.Allocator_Error,
) #optional_allocator_error {
    context.allocator = allocator
    return strings.join(components, NAMESPACE_SEPARATOR)
}

create_namespace :: proc {
    create_namespace_from_components,
}
