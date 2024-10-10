package logging_tests

//-- Standard Library
import "core:testing"

//-- Project Code
import m "lib:logging"
import test_utils "test_utils:."

@(test)
test_create_namespace_from_components :: proc(t: ^testing.T) {
    //-- Given
    components := []string{"a", "b", "c"}

    //-- When
    r := m.create_namespace_from_components(components)

    //-- Then
    test_utils.expect_equal(t, r, "a:b:c")
}
