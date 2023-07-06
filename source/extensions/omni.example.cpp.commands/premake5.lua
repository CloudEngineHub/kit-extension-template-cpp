-- Setup the extension.
local ext = get_current_extension_info()
project_ext(ext)

-- Link folders that should be packaged with the extension.
repo_build.prebuild_link {
    { "data", ext.target_dir.."/data" },
    { "docs", ext.target_dir.."/docs" },
    { "omni", ext.target_dir.."/omni" },
}

-- Build the C++ plugin that will be loaded by the extension.
project_ext_plugin(ext, "omni.example.cpp.commands.plugin")
    local plugin_name = "omni.example.cpp.commands"
    add_files("source", "plugins/"..plugin_name)
    includedirs { "plugins/"..plugin_name }

-- Build the C++ plugin that will be loaded by the tests.
project_ext_tests(ext, "omni.example.cpp.commands.tests")
    local plugin_name = "omni.example.cpp.commands.tests"
    add_files("source", "plugins/"..plugin_name)
    includedirs { "plugins/"..plugin_name, "%{target_deps}/doctest/include" }

    -- Temp: Should have been set by project_ext_tests
    libdirs {
        "%{kit_sdk}/exts/omni.kit.test/bin",
    }
