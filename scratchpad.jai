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

#insert #run generate_kind_enum_from_base_struct(Entity);

main :: () {
    x1 := 3.14;
    
    kind : EntityKind = .Dwarf;

    if #complete kind == {
        case .Dwarf;  { print("im a dwarf");  }
        case .Goblin; { print("im a goblin"); }
    }
}
