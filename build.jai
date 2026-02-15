
#import "Basic";
#import "String";
#import "System";

#if OS == .WINDOWS {
    Windows_Resources :: #import "Windows_Resources";
    Ico_File :: #import "Ico_File";
}

#import "Process";

Compiler :: #import "Compiler";

#run build_simple_examples();

make_return_statement :: (expression: *Compiler.Code_Node) -> *Compiler.Code_Return {
    ret := New(Compiler.Code_Return);
    ret.kind = .RETURN;

    arguments_unsorted: [..] Compiler.Code_Argument;

    arg: Compiler.Code_Argument;
    arg.expression = expression;
    arg.name = null;

    array_add(*arguments_unsorted, arg);
    ret.arguments_unsorted = arguments_unsorted;

    arguments_sorted: [..] *Compiler.Code_Node;
    array_add(*arguments_sorted, expression);
    ret.arguments_sorted = arguments_sorted;

    return ret;
}

build_simple_examples :: () {
    create_workspace :: (opts: Compiler.Build_Options, workspace_name := "") -> Workspace {
        w := Compiler.compiler_create_workspace(workspace_name);
        Compiler.set_build_options(opts, w);
        return w;
    }

    opts := Compiler.get_build_options();

    // Disable executable generation for the current workspace.
    // This makes this workspace compile-time metaprogramming
    // only.
    Compiler.set_build_options_dc(.{do_output=false});

    set_working_directory(#filepath);

    {
        opts.output_type = .EXECUTABLE;
        opts.use_custom_link_command = true;
        opts.output_executable_name = "Dwarfs Clone";

        ws := create_workspace(opts);
        Compiler.compiler_begin_intercept(ws);

        Compiler.add_build_file("main.jai", ws);

        while true {
            message := Compiler.compiler_wait_for_message();
            if message.kind == .COMPLETE break;

            if message.kind == .PHASE {
                phase_message := cast(*Compiler.Message_Phase) message;
                phase := phase_message.phase;
        
                if phase == .READY_FOR_CUSTOM_LINK_COMMAND {
                    use_system_linker_if_able := true; // Use link.exe on Windows, ld on Linux/MacOS
                    run_custom_link_command(message.workspace, phase_message, use_system_linker_if_able=use_system_linker_if_able);
                }
            }
        }

        Compiler.compiler_end_intercept(ws);

        // Using Windows_Resources and Ico_File to set the icon and manifest data for example2.
        #if OS == .WINDOWS {
            exe_name := sprint("%.exe", opts.output_executable_name);
            defer free(exe_name);

            // TODO
            // ico_data := Ico_File.create_ico_file_from_bitmap_filename("data/Terraria2/Item_54.png");
            // defer free(ico_data);
            // Windows_Resources.set_icon_by_data(exe_name, ico_data);

            manifest_options: Windows_Resources.Manifest_Options;
            Windows_Resources.add_manifest_to_executable(exe_name, manifest_options);
        }
    }
}

run_custom_link_command :: (w: Workspace, m: *Compiler.Message_Phase, use_system_linker_if_able := true) {
    options := Compiler.get_build_options(w);

    // Use the workspace's Os_Target since we want to support
    // cross-compilation at some point!
    target := options.os_target;
    target_windows := target == .WINDOWS;
    target_linux   := target == .LINUX;
    target_macosx  := target == .MACOS;

    use_lld := !((target == OS) && use_system_linker_if_able);

    #if OS == .WINDOWS {
        system_linker_exe_name := "link.exe";
    }

    #if OS == .LINUX || OS == .MACOS {
        system_linker_exe_name := "ld";
    }

    #if OS == .WINDOWS {
        if !use_lld && target_windows {
            // If we have opted to use the system linker and we're on Windows,
            // then attempt to find link.exe, otherwise fallback to LLD (or maybe error?)
            vc_path, linker_path := Windows_Resources.find_visual_studio_in_a_ridiculous_garbage_way();
            if linker_path {
                system_linker_exe_name = tprint("%\\%", linker_path, system_linker_exe_name);
            } else {
                Compiler.compiler_report("Could not find link.exe path, falling back to using LLD", mode=.WARNING);
                use_lld = true;
            }
        }
    }

    suffix := "";
    #if OS == .WINDOWS {
        suffix = ".exe";
    }

    target_filename := tprint("%1%2%3", options.output_path, options.output_executable_name, suffix);

    lld_exe_name: string;
    if use_lld {
        compiler_base_path := Compiler.compiler_get_base_path();

        #if OS == .WINDOWS  lld := "lld.exe";
        #if OS == .MACOS    lld := "lld-macosx";
        #if OS == .LINUX    lld := "lld-linux";

        lld_exe_name = tprint("%/bin/%", compiler_base_path, lld);
    }


    // Unfortunately, right now we are using CreateProcessW because that allows
    // one to be specific about security, etc (or if it isn't specific enough we can
    // change to CreateProcessExW). HOWEVER, it doesn't inherit the path so we need
    // to provide the path explicitly. That sucks. Maybe we have to change to system.
    // Or duplicate system's ability to use the path.

    arguments: [..] string;

    if use_lld {
        array_add(*arguments, lld_exe_name);
        array_add(*arguments, "-flavor");

        // choose the flavor based on the target OS.
        if      target_windows array_add(*arguments, "link");
        else if target_linux   array_add(*arguments, "Gnu");
        else if target_macosx  array_add(*arguments, "Darwin");
    } else {
        array_add(*arguments, system_linker_exe_name);
    }

    if target_windows array_add(*arguments, "/nologo");

    // Object files.
    for m.compiler_generated_object_files array_add(*arguments, it);
    for m.support_object_files array_add(*arguments, it);

    if target_windows {
        // Target filename.
        array_add(*arguments, tprint("/OUT:%", target_filename));

        array_add(*arguments, "/STACK:16777216");
        array_add(*arguments, "/MACHINE:AMD64");
        array_add(*arguments, "/INCREMENTAL:NO");
        array_add(*arguments, "/DEBUG");

        // If generating an executable, then create lib and exp file inside intermediate directory.
        if options.output_type == .EXECUTABLE {
            array_add(*arguments, tprint("/IMPLIB:%1/%2.lib", options.intermediate_path, path_strip_extension(options.output_executable_name)));
        }
    } else if target_linux {
        array_add(*arguments, "--eh-frame-hdr");
        array_add(*arguments, "-export-dynamic");
        array_add(*arguments, tprint("-o%", target_filename));
        array_add(*arguments, "--dynamic-linker");
        array_add(*arguments, "/lib64/ld-linux-x86-64.so.2");
        array_add(*arguments, "-rpath=$ORIGIN");
    } else { // target_macosx
        array_add(*arguments, "-export_dynamic");
        array_add(*arguments, "-dynamic");
        array_add(*arguments, "-o");
        array_add(*arguments, target_filename);

        array_add(*arguments, "-macosx_version_min");
        array_add(*arguments, "10.13");

        array_add(*arguments, "-rpath");
        array_add(*arguments, "@loader_path"); // NOTE: on the command-line we have to single-quote this, here it must be unquoted!
    }

    // @TODO we probably need to do something similar using LLD on non-Windows hosts
    #if OS == .WINDOWS {
        if target_windows {
            vc_path := Windows_Resources.find_visual_studio_in_a_ridiculous_garbage_way();
            if vc_path {
                array_add(*arguments, tprint("/libpath:\"%\"", vc_path));
            } else {
                Compiler.compiler_report(#file, #line, 0, "Unable to find Visual Studio runtime library folder; can't compile.\n");
            }

            kit_root, windows_version := Windows_Resources.find_windows_kit_root();
            if kit_root {
                // I guess both Windows 8 and 10 use the same um / ucrt format.
                // kit_root does not have a slash at the end!! Sigh.
                array_add(*arguments, tprint("/libpath:\"%/um/x64\"", kit_root));
                array_add(*arguments, tprint("/libpath:\"%/ucrt/x64\"", kit_root));
            } else {
                // Report error.
                Compiler.compiler_report(#file, #line, 0, "Unable to find Windows Kit root; can't compile.\n");
            }


            if (options.output_type == .DYNAMIC_LIBRARY) {
                array_add(*arguments, "/DLL");
            }

            array_add(*arguments, "-nodefaultlib");
        }
    }

    for m.user_libraries      array_add(*arguments, it);
    for m.system_libraries    array_add(*arguments, it);

    print("Link line: %\n", get_quoted_command_string(arguments));
    process_result := run_command(..arguments);

    if process_result.exit_code != 0 {
        print("Error: Link step failed! (Exit code %).\n", process_result.exit_code);
    }

    // Report to the compiler that we have finished linking
    Compiler.compiler_custom_link_command_is_complete(w);
}
