# Overview

An [example C++ extension](http://omniverse-docs.s3-website-us-east-1.amazonaws.com/kit-extension-template-cpp/106.0.1/index.html) that can be used as a reference/template for creating new extensions.

Demonstrates how to reflect C++ code using pybind11 so that it can be called from Python code.

The IExampleBoundInterface located in `include/omni/example/cpp/pybind/IExampleBoundInterface.h` is:
- Implemented in `plugins/omni.example.cpp.pybind/ExamplePybindExtension.cpp`.
- Reflected in `bindings/python/omni.example.cpp.pybind/ExamplePybindBindings.cpp`.
- Accessed from Python in `python/tests/test_pybind_example.py` via `python/impl/example_pybind_extension.py`.


# C++ Usage Examples


## Defining Pybind Module


```
PYBIND11_MODULE(_example_pybind_bindings, m)
{
    using namespace omni::example::cpp::pybind;

    m.doc() = "pybind11 omni.example.cpp.pybind bindings";

    carb::defineInterfaceClass<IExampleBoundInterface>(
        m, "IExampleBoundInterface", "acquire_bound_interface", "release_bound_interface")
        .def("register_bound_object", &IExampleBoundInterface::registerBoundObject,
             R"(
             Register a bound object.

             Args:
                 object: The bound object to register.
             )",
             py::arg("object"))
        .def("deregister_bound_object", &IExampleBoundInterface::deregisterBoundObject,
             R"(
             Deregister a bound object.

             Args:
                 object: The bound object to deregister.
             )",
             py::arg("object"))
        .def("find_bound_object", &IExampleBoundInterface::findBoundObject, py::return_value_policy::reference,
             R"(
             Find a bound object.

             Args:
                 id: Id of the bound object.

             Return:
                 The bound object if it exists, an empty object otherwise.
             )",
             py::arg("id"))
        /**/;

    py::class_<IExampleBoundObject, carb::ObjectPtr<IExampleBoundObject>>(m, "IExampleBoundObject")
        .def_property_readonly("id", &IExampleBoundObject::getId, py::return_value_policy::reference,
            R"(
             Get the id of this bound object.

             Return:
                 The id of this bound object.
             )")
        /**/;

    py::class_<PythonBoundObject, IExampleBoundObject, carb::ObjectPtr<PythonBoundObject>>(m, "BoundObject")
        .def(py::init([](const char* id) { return PythonBoundObject::create(id); }),
             R"(
             Create a bound object.

             Args:
                 id: Id of the bound object.

             Return:
                 The bound object that was created.
             )",
             py::arg("id"))
        .def_readwrite("property_int", &PythonBoundObject::m_memberInt,
             R"(
             Int property bound directly.
             )")
        .def_readwrite("property_bool", &PythonBoundObject::m_memberBool,
             R"(
             Bool property bound directly.
             )")
        .def_property("property_string", &PythonBoundObject::getMemberString, &PythonBoundObject::setMemberString, py::return_value_policy::reference,
             R"(
             String property bound using accessors.
             )")
        .def("multiply_int_property", &PythonBoundObject::multiplyIntProperty,
             R"(
             Bound fuction that accepts an argument.

             Args:
                 value_to_multiply: The value to multiply by.
             )",
             py::arg("value_to_multiply"))
        .def("toggle_bool_property", &PythonBoundObject::toggleBoolProperty,
             R"(
             Bound fuction that returns a value.

             Return:
                 The toggled bool value.
             )")
        .def("append_string_property", &PythonBoundObject::appendStringProperty, py::return_value_policy::reference,
             R"(
             Bound fuction that accepts an argument and returns a value.

             Args:
                 value_to_append: The value to append.

             Return:
                 The new string value.
             )",
             py::arg("value_to_append"))
        /**/;
}
```

