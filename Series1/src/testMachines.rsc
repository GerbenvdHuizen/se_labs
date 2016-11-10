module testMachines

extend lang::std::Layout;
extend lang::std::Id;

start syntax Machine = machine: State+ states;
syntax State = @Foldable state: "state" Id name Trans* out;
syntax Trans = trans: Id event ":" Id to;

set[Id] unreachable(Machine m) {
  r = { <q1,q2> | (State)`state <Id q1> <Trans* ts>` <- m.states, 
				  (Trans)`<Id _>: <Id q2>` <- ts }+;
  qs = [ q.name | /State q := m ];
  return { q | q <- qs, q notin r[qs[0]] };
}

str compile(Machine m) =
  "while (true) {
  '  event = input.next();
  '  switch (current) { 
  '    <for (q <- m.states) {>
  '    case \"<q.name>\":
  '      <for (t <- q.out) {>
  '      if (event.equals(\"<t.event>\"))
  '        current = \"<t.to>\";
  '      <}>
  '      break;
  '    <}>
  '  }
  '}"; 