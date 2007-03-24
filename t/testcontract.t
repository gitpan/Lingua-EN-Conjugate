use Test;

BEGIN { plan tests => 14 }	

use Lingua::EN::Conjugate qw( contraction );
use Data::Dumper;

ok(contraction("he is not walking"), 
	"he isn't walking");

ok(contraction("he is not walking", 0, 1), 
	"he's not walking");

ok(contraction("I would like to say that it is very nice that you are here"), 
	"I'd like to say that it's very nice that you're here");

ok(contraction("you are not happy"), 
	"you aren't happy");

ok(contraction("is it not nice?"), 
	"isn't it nice?");

ok(contraction("are you not amused?"), 
	"aren't you amused?");

ok(contraction("let us go see whether we can not find it", 1), 
	"let's go see whether we can't find it");


ok(contraction("let us go see whether we can not find it", 0), 
	"let's go see whether we can not find it");

ok(contraction("let us go see whether we can not find it", 1, 0), 
	"let us go see whether we can't find it");


ok(contraction("should I have been walking"), 
	"should I have been walking");

ok(contraction("should I not have been walking"), 
	"shouldn't I have been walking");

ok(contraction("I could have been walking"), 
	"I could've been walking");

ok(contraction("I could not have been walking"), 
	"I couldn't have been walking");

ok(contraction("I could not have been walking", 0, 1), 
	"I could not have been walking");
