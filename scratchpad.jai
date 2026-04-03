#import "Basic";
Compiler :: #import "Compiler";
#import "Hash_Table";
#import "Input";
#import "Math";
#import "Print_Vars";
#import "Random";
#import "Sort";
#import "System";

#load "utils.jai";

#run {
  Compiler.set_build_options_dc(.{do_output=false});

  for 1..1 {
    print("%\n", it);
  }
}