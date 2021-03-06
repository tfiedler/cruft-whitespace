#!/usr/bin/perl

use strict;
use warnings;

my @col1;
my @col2;
my @col3;
while (<DATA>)
{
    chomp;
    my ( $col1, $col2, $col3 ) = split /\s+/, ;
    push @col1, $col1 if ( defined $col1 && $col1 =~ /^\w+/ );
    push @col2, $col2 if ( defined $col2 && $col2 =~ /^\w+/ );
    push @col3, $col3 if ( defined $col3 && $col3 =~ /^\w+/ );
}

print "thou $col1[rand @col1] $col2[rand @col2] $col3[rand @col3]\n";

# DATA was pulled from http://www.pangloss.com/seidel/shake_rule.html

__DATA__
artless             base-court          apple-john
bawdy               bat-fowling         baggage
beslubbering        beef-witted         barnacle
bootless            beetle-headed       bladder
churlish            boil-brained        boar-pig
cockered            clapper-clawed      bugbear
clouted             clay-brained        bum-bailey
craven              common-kissing      canker-blossom
currish             crook-pated         clack-dish
dankish             dismal-dreaming     clotpole
dissembling         dizzy-eyed          coxcomb
droning             doghearted          codpiece
errant              dread-bolted        death-token
fawning             earth-vexing        dewberry
fobbing             elf-skinned         flap-dragon
froward             fat-kidneyed        flax-wench
frothy              fen-sucked          flirt-gill
gleeking            flap-mouthed        foot-licker
goatish             fly-bitten          fustilarian
gorbellied          folly-fallen        giglet
impertinent         fool-born           gudgeon
infectious          full-gorged         haggard
jarring             guts-griping        harpy
loggerheaded        half-faced          hedge-pig
lumpish             hasty-witted        horn-beast
mammering           hedge-born          hugger-mugger
mangled             hell-hated          joithead
mewling             idle-headed         lewdster
paunchy             ill-breeding        lout
pribbling           ill-nurtured        maggot-pie
puking              knotty-pated        malt-worm
puny                milk-livered        mammet
qualling            motley-minded       measle
rank                onion-eyed          minnow
reeky               plume-plucked       miscreant
roguish             pottle-deep         moldwarp
ruttish             pox-marked          mumble-news
saucy               reeling-ripe        nut-hook
spleeny             rough-hewn          pigeon-egg
spongy              rude-growing        pignut
surly               rump-fed            puttock
tottering           shard-borne         pumpion
unmuzzled           sheep-biting        ratsbane
vain                spur-galled         scut
venomed             swag-bellied        skainsmate
villainous          tardy-gaited        strumpet
warped              tickle-brained      varlot
wayward             toad-spotted        vassal
weedy               unchin-snouted      whey-face
yeasty              weather-bitten      wagtail
cullionly           whoreson            knave
fusty               malmsey-nosed       blind-worm
caluminous          rampallian          popinjay
wimpled             lily-livered        scullian
burly-boned         scurvy-valiant      jolt-head
misbegotten         brazen-faced        malcontent
odiferous           unwash'd            devil-monk
poisonous           bunch-back'd        toad
fishified           leaden-footed       rascal
Wart-necked         muddy-mettled       Basket-Cockle
                    pigeon-liver'd
                    scale-sided

