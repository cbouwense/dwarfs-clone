#import "Basic";
#import "Compiler";
#import "Print_Vars";

Entity :: struct {
    id: s32;
}

Dwarf :: struct {
    #as using entity: Entity;
    axe_id: s32;
}

Goblin :: struct {
    #as using entity: Entity;
    sword_id: s32;
}

foo :: () -> string {
    entity_subclasses : [..] string;

    table := get_type_table();         // (1) 

    print("The type table has % entries: \n", table.count); 

    for ti: table {
        if uses_entity_with_as(ti) {
            print("%: ", it_index);
            print("  type: % ", ti.type); 
            print("FOUND YOU\n");
            tis := cast(*Type_Info_Struct) ti;
            array_add(*entity_subclasses, tis.name);
        }
    }

    // print_vars(entity_subclasses);

    builder: String_Builder;
    print_to_builder(*builder, "EntityKind :: enum {\n");
    for entity_subclasses {
        print_to_builder(*builder, "    %;\n", it);
    }
    print_to_builder(*builder, "}\n");
    
    // return builder_to_string(*builder);

    return builder_to_string(*builder);
};

#insert #run foo();

main :: () {
    x1 := 3.14;
    
    kind : EntityKind = .Dwarf;

    if #complete kind == {
        case .Dwarf; { print("im a dwarf"); }
        case .Goblin; { print("im a dwarf"); }
    }
}

uses_entity_with_as :: (ti: *Type_Info) -> bool #compile_time {
    if ti.type != .STRUCT return false;

    tis := cast(*Type_Info_Struct) ti;
    for tis.members {
        if !(it.flags & .AS)             continue;
        if it.type != type_info(Entity) continue;

        // We found a relevant member!
        return true;
    }

    return false;
}
