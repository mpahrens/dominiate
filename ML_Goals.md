== Goals for COMP150AML ==
- Be able to run fresh simulator, with copied state, at any point.
- Represent a strategy aggregator which is a strategy of switching over strategies
- Represent a strategy transformer which is a strategy with methods to change its parameters.
- Be able to query the policy collection
- policy switching: to make decisions of which expert policy to follow against a fixed set of cards and opponent strategy
- policy gradient / policy search: to improve upon a base policy by tweaking parameters against a fixed set of cards and opponent strategy.

== Info ==
- play.coffee has main state game loop
    - has access to state variable in until loop

== stuff to find out ==
- Does state st have a copy constructor
- Print stuff to the log
- how to take an ai, replace the strategy
