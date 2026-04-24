#import "Basic";
Compiler :: #import "Compiler";
#import "Hash_Table";
#import "Input";
#import "Math";
#import "Print_Vars";
#import "Random";
#import "Sort";
#import "System";

#load "main.jai";

#run {
  Compiler.set_build_options_dc(.{do_output=false});



  print("%\n", get_tile_pos_by_id(2001932));
}