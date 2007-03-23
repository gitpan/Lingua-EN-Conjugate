
use Test;

BEGIN { plan tests => 17 }	

use Lingua::EN::Conjugate qw( conjugate conjugations );
use Data::Dumper;


	ok(conjugate( 'verb' => 'have', 'tense' => 'present', 'pronoun' => 'he' ), 'he has');
	ok(conjugate('verb'=>'study', 'pronoun'=>'she', 'tense'=>'present'), 'she studies');
	ok(conjugate( 'verb' => 'have', 'tense' => 'past', 'pronoun' => 'I' ), 'I had');
	ok(conjugate('verb'=>'do not invite', 'pronoun'=>'I', 'tense'=>'past'), 'I didn\'t invite');
	ok(conjugate('verb'=>'do not go', 'pronoun'=>'you', 'tense'=>'imperative'), 'don\'t go');
	ok(conjugate('verb'=>'do not? see', 'pronoun'=>'she', 'tense'=>'present'), 'doesn\'t she see');

	# scalar context with tense and pronoun defined as scalars, 
	#returns a scalar
	my $walk = conjugate( 'verb'=>'walk', 
				'tense'=>'perfect_prog', 
				'pronoun'=>'he' );  
	print "# $walk \n";
	ok($walk, 'he has been walking');

	# scalar context with tense and pronoun undefined or defined 
	#as array refs, returns a hashref
	my $go = conjugate( 'verb'=>'go', 
				'tense'=>[qw(past_prog modal)], 
				'modal'=>'used to' ) ;       	
	ok(ref $go, 'HASH');
	ok($go->{past_prog}{I}, 'I was going');

	# array context, returns an array of conjugated forms
	my @be = conjugate( 'verb'=>'be', 
				'pronoun'=>[qw(I we)], 
				'tense'=>[qw(present past_prog)] );
	print "# " . join("\n# ", @be);
	print "\n";
	ok(scalar @be, 4);
	
	ok(conjugate('verb'=>'enter', 'pronoun'=>'I', 'tense'=>'past'), 'I entered');
	ok(conjugate('verb'=>'visit', 'pronoun'=>'I', 'tense'=>'past'), 'I visited');
	ok(conjugate('verb'=>'refer', 'pronoun'=>'I', 'tense'=>'past'), 'I referred');
	ok(conjugate('verb'=>'begin', 'pronoun'=>'I', 'tense'=>'past'), 'I began');
	ok(conjugate('verb'=>'do? go', 'pronoun'=>'you', 'tense'=>'past'), 'did you go');
	ok(conjugate('verb'=>'do not happen', 'pronoun'=>'it', 'tense'=>'past'), 'it didn\'t happen');
	ok(conjugate('verb'=>'prefer', 'pronoun'=>'they', 'tense'=>'modal_perf', 'modal'=>'would'), 'they would have preferred');


	

