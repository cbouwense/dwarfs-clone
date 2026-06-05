#import "Basic";
#import "Compiler";
#import "Print_Vars";
#import "Program_Print";

#run {
    set_build_options_dc(.{do_output=false});

    debug_struct_fields_with_raylib_draw_text :: (struct_symbol: Code) #expand {
        // Get the AST of the struct symbol. In this case, it should just be one node.
        // In fact, let's assert that.
        struct_ast_node, expressions := compiler_get_nodes(struct_symbol);
        assert(expressions.count == 1);

        builder: String_Builder;
        print_expression(*builder, struct_ast_node);

        struct_as_string := builder_to_string(*builder);
        print_vars(struct_as_string);
    }

    Foo :: struct { bar: int; baz: string; };
    the_foo := Foo.{ 42, "the answer" };

    debug_struct_fields_with_raylib_draw_text(#code the_foo);
}
