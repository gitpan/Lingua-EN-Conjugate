package Lingua::EN::Conjugate;

use Data::Dumper;
require Exporter;

@ISA = qw( Exporter );

@EXPORT_OK = qw(
  conjugate
  conjugations
  @tenses
  @pron
);

#use warnings;
#use strict;
#use diagnostics;

use vars qw(
  $VERSION
  %irreg
  @pron
  @tenses
  %conj
  %no_double

);

$VERSION = '0.22';
@pron    = qw(I you we he she it they);

@tenses = qw(	present
  present_prog
  past
  past_prog
  perfect
  past_perfect
  perfect_prog
  past_perfect_prog
  modal
  modal_prog
  modal_perf
  modal_perf_prog
  conjunctive_present
  imperative
);

while (<DATA>) {
    chomp;
    next if /\[IRREG\]/;
    last if /\[NO-DOUBLE\]/;
    next unless /\w/;
    my ( $verb, $simp, $part ) = split /-/, $_;

    $verb =~ s/\(.*//;
    $simp =~ s/\/.*//;
    $part =~ s/\/.*//;
    ( $verb, $simp, $part ) =
      map { s/^\s*|\s*$//g; $_ } ( $verb, $simp, $part );
    $irreg{$verb} = { past => $simp, part => $part };
    #print "$verb, $simp, $part\n";

}
while (<DATA>) {
    my $line = $_;
    chomp $line;
    $line =~ s/^ *| *$//g;
    my @nd = split / /, $line;
    $no_double{$_} = 1 for @nd;
}


sub conjugate {

    my %params = @_;

    #print Dumper \%params;

    my $inf =
      defined $params{verb} ? $params{verb} : warn "must define a verb!!\n",
      return;
    $inf =~ s/^ *| *$//g;
    $inf =~ s/  *//g;
    my $modal = defined $params{modal} ? $params{modal} : 'will';
    my @conjs = ();

    my $do;
    $do->{helper}   = '';
    $do->{question} = '';
    $do->{not}      = '';

    # special case for "we do.. " "you did.." "didn't they ..." and so on
    if ( $inf =~ s/(do) ?(not)?(\??) ?(\w+)// ) {
        $inf            = $1;
        $do->{not}      = $2;
        $do->{question} = $3;
        $do->{helper}   = $4;

        #print "do conjug: $inf, $do->{not}, $do->{question}, $do->{helper}\n";
    }

    my ( $part, $past, $gerund );

    my $stem = $inf;

    if ( $stem =~ /[bcdfghjklmnpqrstvwxyz][aeiou][bcdfghjklmnpqrstv]$/ ) {

       #if the word ends in CVC pattern (but final consonant is not w,x,y, or z)
       # and if the stress is not on the penultimate syllable, then double
       # the final consonant.
       #
       # works for stop, sit, spit, refer, begin, admit, etc.
       # but breaks for visit, happen, enter, etc.

        $stem =~ s/(\w)$/$1$1/ unless $no_double{$stem};

    }

    $part = $stem . 'ed';
    $part =~ s/([bcdfghjklmnpqrstvwxyz])eed$/$1ed/;
    $part =~ s/([bcdfghjklmnpqrstvwxyz])yed$/$1ied/;
    $part =~ s/eed$/ed/;
    $past = $part;

    $gerund = $stem . 'ing';
    $gerund =~ s/([bcdfghjklmnpqrstvwxyz])eing$/$1ing/;
    $gerund =~ s/ieing$/ying/;
    $gerund =~ s/eed$/ed/;

    if ( $inf eq 'be' ) {
        $gerund = 'being';
    }

    if ( defined $irreg{$inf} ) {
        $part = $irreg{$inf}{part};
        $past = $irreg{$inf}{past};
    }

    my $e = $inf =~ /[ho]$/ ? 'e' : '';

    #print "[$inf], [$past], [$part]\n";

    my %conj = (

        present => {
            ( map { $_ => $_ . " $inf" } qw(I you we they) ),
            ( map { $_ => $_ . " ${inf}${e}s" } qw(he she it) )
        },

        present_prog => {
            ( map { $_ => $_ . " am $gerund" } qw(I) ),
            ( map { $_ => $_ . " are $gerund" } qw(you we they) ),
            ( map { $_ => $_ . " is $gerund" } qw(he she it) )
        },

        past => { map { $_ => $_ . " $past" } @pron },

        past_prog => {
            ( map { $_ => $_ . " were $gerund" } qw(you we they) ),
            ( map { $_ => $_ . " was $gerund" } qw(I he she it) )
        },

        perfect => {
            ( map { $_ => $_ . " have $part" } qw(I you we they) ),
            ( map { $_ => $_ . " has $part" } qw(he she it) )
        },

        past_perfect => { map { $_ => $_ . " had $part" } @pron },

        perfect_prog => {
            ( map { $_ => $_ . " have been $gerund" } qw(I you we they) ),
            ( map { $_ => $_ . " has been $gerund" } qw(he she it) )
        },

        past_perfect_prog => { map { $_ => $_ . " had been $gerund" } @pron },

        modal      => { map { $_ => $_ . " $modal $inf" } @pron },
        modal_prog => { map { $_ => $_ . " $modal be $gerund" } @pron },
        modal_perf => { map { $_ => $_ . " $modal have $part" } @pron },
        modal_perf_prog =>
          { map { $_ => $_ . " $modal have been $gerund" } @pron },
        conjunctive_present => { map { $_ => $_ . " $inf" } @pron },
        imperative => { "you" => "$inf", "we" => "let's $inf" },

        used_to => { map { $_ => $_ . " used to $inf" } @pron },

    );

    if ( $inf eq 'be' ) {

        $conj{present} = {
            ( map { $_ => $_ . " am" } qw(I) ),
            ( map { $_ => $_ . " are" } qw(you we they) ),
            ( map { $_ => $_ . " is" } qw(he she it) )
        };
        $conj{past} = {
            ( map { $_ => $_ . " were" } qw(you we they) ),
            ( map { $_ => $_ . " was" } qw(I he she it) )
        };

    }

    if ( $inf eq 'have' ) {
        $conj{present} = {
            ( map { $_ => $_ . " have" } qw(I you we they) ),
            ( map { $_ => $_ . " has" } qw(he she it) )
        };


    }

    if ( $inf eq 'do' and $do->{helper} ne '' ) {
        delete $conj{$_}
          for
          qw(modal_perf perfect perfect_prog modal_prog present_prog past_perfect conjunctive_present used_to
          past_perfect_prog past_prog modal_perf_prog modal);
        for my $t ( keys %conj ) {

            #print "*****" . uc($t) . "******\n";
            for my $p ( keys %{ $conj{$t} } ) {
                next unless defined $conj{$t}{$p};
                my $c = $conj{$t}{$p};
                $c =~ s/  +/ /g;

                #print "before changing word order for do:\n$c\n";
                my ( $pron, $verb, $rest ) =
                  $c =~ /([\w']+)?\s*(do|does|did)\b\s*(\b.*)?/;
		$pron = '' unless defined $pron;
                $verb = '' unless defined $verb;
                $rest   = '' unless defined $rest;
		#print "pron = $pron, verb = $verb, rest = $rest\n";

                if ( defined $do->{not} and $do->{not} eq 'not' ) {
                    $verb .= "n't";
                }

                if ( $do->{question} eq '?' ) {
                    ( $pron, $verb ) = ( $verb, $pron );
                }
                $c = "$pron $verb";

                $c .= " $rest $do->{helper}";
                $c =~ s/  +/ /g;
		$c =~ s/^ *| *$//g;

                #print "after changing word order for do:\n$c\n";
                $conj{$t}{$p} = $c;
            }
        }
    }

    if (   ref $params{pronoun}
        or ref $params{tense}
        or !defined $params{pronoun}
        or !defined $params{tense} )
    {
        my $ret = {};
        my @t =
            ref $params{tense}     ? @{ $params{tense} }
          : defined $params{tense} ? $params{tense}
          :                          @tenses;

        for my $t (@t) {

            my @p =
              ref $params{pronoun} ? grep { defined $conj{$t}{$_} }
              @{ $params{pronoun} }
              : defined $params{pronoun} ? $params{pronoun}
              :                            grep { defined $conj{$t}{$_} } @pron;

            for my $p (@p) {
                next unless defined $conj{$t}{$p};
                $ret->{$t}{$p} = $conj{$t}{$p};
            }
        }

        if (wantarray) {
            my @return = ();
            for my $t ( keys %{$ret} ) {
                for my $p ( keys %{ $ret->{$t} } ) {

                    push @return, $ret->{$t}{$p};
                }
            }
            return @return;
        }
        else { return $ret }

    }

    return $conj{ $params{tense} }{ $params{pronoun} };

}

sub conjugations {

    my ( $tense, $pronoun, $result, @_tenses );

    my @pnouns = qw(I you he we they);

    my $conjugs = conjugate(@_);

    @_tenses = grep { defined $conjugs->{$_} } @tenses;

    $result = "";
    foreach ( $tense = 0 ; $tense <= $#_tenses ; $tense += 2 ) {
        my $t1 = $_tenses[$tense];
        my $t2 = $tense < scalar @_tenses ? $_tenses[ $tense + 1 ] : undef;
        $result .= centered( uc( $_tenses[$tense] ),       35, "-" );
        $result .= " ";
        $result .= centered( uc( $_tenses[ $tense + 1 ] ), 35, "-" )
          if defined $t2;
        $result .= "\n";
        for $pronoun (@pnouns) {
            my $s1 =
              defined $conjugs->{$t1}{$pronoun}
              ? $conjugs->{$t1}{$pronoun}
              : '';
            my $s2 =
                 defined $t2
              && defined $conjugs->{$t2}{$pronoun}
              ? $conjugs->{$t2}{$pronoun}
              : '';
            $result .= sprintf "%-35s %-35s\n", $s1, $s2;

        }
    }
    return $result;

    sub centered {
        my ( $string, $len, $fill ) = @_;
        $fill = " " unless defined $fill;
        my $result = $fill x ( ( $len - length($string) ) / 2 - 1 );
        $result .= " ";
        $result .= $string;
        $result .= " ";
        $result .= $fill x ( $len - length($result) );
        return $result;
    }
}

"true";

=head1 NAME

Lingua::EN::Conjugate - Conjugation of English verbs

=head1 SYNOPSIS

use Lingua::EN::Conjugate qw( conjugate conjugations );
use Data::Dumper;
	

	# scalar context with tense and pronoun defined as scalars, 
	#returns a scalar
	my $walk = conjugate( 'verb'=>'walk', 
				'tense'=>'perfect_prog', 
				'pronoun'=>'he' );  
	print $walk . "\n";

	# scalar context with tense and pronoun undefined or defined 
	#as array refs, returns a hashref
	my $go = conjugate( 'verb'=>'go', 
				'tense'=>[qw(past modal_perf)], 
				'modal'=>'might not' ) ;       	
	print Dumper($go);

	# array context, returns an array of conjugated forms
	my @be = conjugate( 'verb'=>'be', 
				'pronoun'=>[qw(I we)], 
				'tense'=>'past_prog' );

	print join("\n", @be);

	print conjugations( 'verb'=>'walk' );



=head1 DESCRIPTION

This module conjugates English verbs.

Thanks to Susan Jones for the list of irregular verbs and an explanation of English verb tenses: http://www2.gsu.edu/~wwwesl/egw/grlists.htm.

	present         	-> we drive
	present_prog    	-> we are driving
	past           	 	-> we drove
	past_prog       	-> we were driving
	perfect         	-> we have driven
	past_perfect    	-> we had driven
	perfect_prog    	-> we have been driving
	past_perfect_prog 	-> we had been driving
	modal           	-> we will drive
	modal_prog      	-> we will be driving
	modal_perf      	-> we will have driven
	modal_perf_prog 	-> we will have been driving
	conjunctive_present 	-> we drive
	imperative      	-> let's drive

See http://www.englishclub.com/grammar/verbs-modals_can.htm. 

=over

=item conjugate()

  this conjugates a verb.



=item conjugations()
  
   returns a pretty-printed table of conjugations.  (code stolen from L<Lingua::IT::Conjugate>)

=back

=head2 EXPORT

None by default. You can export the following functions and variables:

	conjugate
	@tenses
	@pronouns

=head1 BUGS


=head1 HISTORY

=over 4

=item 0.1

Original version -- no guarantees.

=item 0.2
	
Added a stop-list for words that shouldn't have the final consonant doubled when adding
-ed or -ing.

=item 0.21

nothin much, just fixing the documentation...

=back


=head1 AUTHOR

Russ Graham, russgraham@gmail.com

=head1 SEE ALSO

perl(1).

=cut

__DATA__
[IRREG]
awake - awoke - awoken
be - was, were - been
bear - bore - born
beat - beat - beat
become - became - become
begin - began - begun
bend - bent - bent
beset - beset - beset
bet - bet - bet
bid - bid/bade - bid/bidden
bind - bound - bound
bite - bit - bitten
bleed - bled - bled
blow - blew - blown
break - broke - broken
breed - bred - bred
bring - brought - brought
broadcast - broadcast - broadcast
build - built - built
burn - burned/burnt - burned/burnt
burst - burst - burst
buy - bought - bought
cast - cast - cast
catch - caught - caught
choose - chose - chosen
cling - clung - clung
come - came - come
cost - cost - cost
creep - crept - crept
cut - cut - cut
deal - dealt - dealt
dig - dug - dug
dive - dove/dived - dived
do - did - done
draw - drew - drawn
dream - dreamed/dreamt - dreamed/dreamt
drive - drove - driven
drink - drank - drunk
eat - ate - eaten
fall - fell - fallen
feed - fed - fed
feel - felt - felt
fight - fought - fought
find - found - found
fit - fit - fit
flee - fled - fled
fling - flung - flung
fly - flew - flown
forbid - forbade - forbidden
forget - forgot - forgotten
forego - forewent - foregone
forgo - forwent - forgone
forgive - forgave - forgiven
forsake - forsook - forsaken
freeze - froze - frozen
get - got - gotten
give - gave - given
go - went - gone
grind - ground - ground
grow - grew - grown
hang - hung - hung
have - had - had
hear - heard - heard
hide - hid - hidden
hit - hit - hit
hold - held - held
hurt - hurt - hurt
keep - kept - kept
kneel - knelt - knelt
knit - knit - knit
know - knew - know
lay - laid - laid
lead - led - led
leap - leaped/lept - leaped/lept
learn - learned/learnt - learned/learnt
leave - left - left
lend - lent - lent
let - let - let
lie - lay - lain
light - lit/lighted - lighted
lose - lost - lost
make - made - made
mean - meant - meant
meet - met - met
misspell - misspelled/misspelt - misspelled/misspelt
mistake - mistook - mistaken
mow - mowed - mowed/mown
overcome - overcame - overcome
overdo - overdid - overdone
overtake - overtook - overtaken
overthrow - overthrew - overthrown
pay - paid - paid
plead - pled - pled
prove - proved - proved/proven
put - put - put
quit - quit - quit
read - read - read
rid - rid - rid
ride - rode - ridden
ring - rang - rung
rise - rose - risen
run - ran - run
saw - sawed - sawed/sawn
say - said - said
see - saw - seen
seek - sought - sought
sell - sold - sold
send - sent - sent
set - set - set
sew - sewed - sewed/sewn
shake - shook - shaken
shave - shaved - shaved/shaven
shear - shore - shorn
shed - shed - shed
shine - shone - shone
shoe - shoed - shoed/shod
shoot - shot - shot
show - showed - showed/shown
shrink - shrank - shrunk
shut - shut - shut
sing - sang - sung
sink - sank - sunk
sit - sat - sat
sleep - slept - slept
slay - slew - slain
slide - slid - slid
sling - slung - slung
slit - slit - slit
smite - smote - smitten
sow - sowed - sowed/sown
speak - spoke - spoken
speed - sped - sped
spend - spent - spent
spill - spilled/spilt - spilled/spilt
spin - spun - spun
spit - spit/spat - spit
split - split - split
spread - spread - spread
spring - sprang/sprung - sprung
stand - stood - stood
steal - stole - stolen
stick - stuck - stuck
sting - stung - stung
stink - stank - stunk
stride - strod - stridden
strike - struck - struck
string - strung - strung
strive - strove - striven
swear - swore - sworn
sweep - swept - swept
swell - swelled - swelled/swollen 
swim - swam - swum
swing - swung - swung
take - took - taken
teach - taught - taught
tear - tore - torn
tell - told - told
think - thought - thought
thrive - thrived/throve - thrived
throw - threw - thrown
thrust - thrust - thrust
tread - trod - trodden
understand - understood - understood
uphold - upheld - upheld
upset - upset - upset
wake - woke - woken
wear - wore - worn
weave - weaved/wove - weaved/woven
wed - wed - wed
weep - wept - wept
wind - wound - wound
win - won - won
withhold - withheld - withheld
withstand - withstood - withstood
wring - wrung - wrung
write - wrote - written

[NO-DOUBLE]
 abandon accouter accredit adhibit administer alter anchor answer attrit audit
 author ballot banner batten bedizen bespatter betoken bewilder billet blacken
 blither blossom bother brighten broaden broider burden caparison catalog censor
 center charter chatter cheapen chipper chirrup christen clobber cluster coarsen
 cocker coedit cohabit concenter corner cover covet cower credit custom dampen
 deafen decipher deflower delimit deposit develop differ disaccustom discover
 discredit disencumber dishearten disinherit dismember dispirit dither dizen
 dodder edit elicit embitter embolden embosom embower empoison empower enamor
 encipher encounter endanger enfetter engender enlighten enter envelop envenom
 environ exhibit exit fasten fatten feather fester filter flatten flatter
 flounder fluster flutter foreshorten founder fritter gammon gather gladden
 glimmer glisten glower greaten hamper hanker happen harden harken hasten
 hearten hoarsen honor imprison inhabit inhibit inspirit interpret iron laten
 launder lengthen liken limber limit linger litter liven loiter lollop louden
 lower lumber madden malinger market matter misinterpret misremember monitor
 moulder murder murmur muster number offer open order outmaneuver overmaster
 pamper pilot pivot plaster plunder powder power prohibit reckon reconsider
 recover redden redeliver register rejigger remember renumber reopen reposit
 rewaken richen roister roughen sadden savor scatter scupper sharpen shatter
 shelter shimmer shiver shorten shower sicken smolder smoothen soften solicit
 squander stagger stiffen stopper stouten straiten strengthen stutter suffer
 sugar summon surrender swelter sypher tamper tauten tender thicken threaten
 thunder totter toughen tower transit tucker unburden uncover unfetter unloosen
 upholster utter visit vomit wander water weaken whiten winter wonder worsen
