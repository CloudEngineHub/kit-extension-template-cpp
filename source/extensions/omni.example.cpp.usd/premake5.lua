-- Setup the extension.
local ext = get_current_extension_info()
project_ext(ext)

-- Link folders that should be packaged with the extension.
repo_build.prebuild_link {
    { "data", ext.target_dir.."/data" },
    { "docs", ext.target_dir.."/docs" },
}

-- Build the C++ plugin that will be loaded by the extension.
project_ext_plugin(ext, "omni.example.cpp.usd.plugin")
    add_files("include", "include/omni/example/cpp/usd")
    add_files("source", "plugins/omni.example.cpp.usd")
    includedirs {
        "include",
        "plugins/omni.example.cpp.usd",
        "%{target_deps}/nv_usd/%{cfg.buildcfg}/include" }
    libdirs { "%{target_deps}/nv_usd/%{cfg.buildcfg}/lib" }
    links { "gf", "sdf", "tf", "usd", "usdGeom", "usdUtils" }
    defines { "NOMINMAX", "TBB_USE_DEBUG=%{cfg.buildcfg == 'debug' and 1 or 0}" }
    buildoptions { "/wd4244 /wd4305" }

-- Build Python bindings that will be loaded by the extension.
project_ext_bindings {
    ext = ext,
    project_name = "omni.example.cpp.usd.python",
    module = "_example_usd_bindings",
    src = "bindings/python/omni.example.cpp.usd",
    target_subdir = "omni/example/cpp/usd"
}
    includedirs { "include" }
    repo_build.prebuild_link {
        { "python/impl", ext.target_dir.."/omni/example/cpp/usd/impl" },
        { "python/tests", ext.target_dir.."/omni/example/cpp/usd/tests" },
    }
