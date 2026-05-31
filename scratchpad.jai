#import "Basic";
#import "Compiler";
#import "Print_Vars";

Entity :: struct {
    id   : s32;
    kind : Type;
}

Dwarf :: struct {
    #as using entity: Entity;
    axe_id: s32;
}

Goblin :: struct {
    #as using entity: Entity;
    sword_id: s32;
}


/**
 * ```
 * Entity :: struct {
 *     id: s32;
 * }
 * 
 * Dwarf :: struct {
 *     #as using entity: Entity;
 *     // dwarf specific fields
 * }
 * 
 * Goblin :: struct {
 *     #as using entity: Entity;
 *     // goblin specific fields
 * }
 *
 * #insert #run generate_kind_enum_from_base_struct(Entity);
 * ```
 * 
 * the above snippet generates the following output
 * 
 * ```
 * EntityKind :: enum {
 *     Dwarf;
 *     Goblin;
 * }
 * ```
 */
generate_kind_enum_from_base_struct :: ($ base_struct: Type) -> string #compile_time {
    uses_entity_with_as :: (ti: *Type_Info, $ as_struct: Type) -> bool #compile_time {
        if ti.type != .STRUCT return false;

        type_info_struct := cast(*Type_Info_Struct) ti;
        for type_info_struct.members {
            if !(it.flags & .AS) continue;
            if it.type != type_info(as_struct) continue;

            return true;
        }

        return false;
    }

    entity_subclasses : [..] string;

    table_type_infos := get_type_table();

    for ti: table_type_infos {
        if uses_entity_with_as(ti, base_struct) {
            type_info_struct := cast(*Type_Info_Struct) ti;
            array_add(*entity_subclasses, type_info_struct.name);
        }
    }

    builder: String_Builder;
    print_to_builder(*builder, "EntityKind :: enum {\n");
    for entity_subclasses {
        print_to_builder(*builder, "    %;\n", it);
    }
    print_to_builder(*builder, "}\n");

    return builder_to_string(*builder);
};

#insert #run generate_kind_enum_from_base_struct(Entity);

main :: () {
    x1 := 3.14;
    
    kind : EntityKind = .Dwarf;

    if #complete kind == {
        case .Dwarf;  { print("im a dwarf");  }
        case .Goblin; { print("im a goblin"); }
    }
}
