package Ged2site::Display::emmigrants;

# Display the emmigrants page

use Ged2site::Display::page;
use Geo::Coder::XYZ;

our @ISA = ('Ged2site::Display::page');
our $geocoder;
our %cache;

sub html {
	my $self = shift;
	my %args = (ref($_[0]) eq 'HASH') ? %{$_[0]} : @_;

	my $info = $self->{_info};
	my $allowed = {
		'page' => 'emmigrants',
		'lang' => qr/^[A-Z][A-Z]/i,
	};
	my $params = $info->params({ allow => $allowed });
	if($params && $params->{'page'}) {
		delete $params->{'page'};
	}

	# Handles into the database
	my $people = $args{'people'};

	# Look in the people.csv for the name given as the CGI argument and
	# find their details
	my $everyone = $people->selectall_hashref($params);

	if(!defined($geocoder)) {
		my $ua = LWP::UserAgent->new();
		$ua->env_proxy(1);
		$geocoder = Geo::Coder::XYZ->new(ua => $ua);
	}

	my @emmigrants;

	foreach my $person(@{$everyone}) {
		next unless($person->{'birth_coords'} && $person->{'death_coords'});
		next if($person->{'birth_coords'} eq $person->{'death_coords'});

		my @b = split(/,/, $person->{'birth_coords'});
		my @d = split(/,/, $person->{'death_coords'});
		next if(::distance($b[0], $b[1], $d[0], $d[1], 'M') <= 100);

		my $birth = $cache{$person->{'birth_coords'}};
		if(!defined($birth)) {
			$birth = $geocoder->reverse_geocode(latlng => $person->{'birth_coords'});
			$cache{$person->{'birth_coords'}} = $birth;
		}
		next unless($birth);
		next if($birth->{error});

		my $death = $cache{$person->{'death_coords'}};
		if(!defined($death)) {
			$death = $geocoder->reverse_geocode(latlng => $person->{'death_coords'});
			$cache{$person->{'death_coords'}} = $death;
		}
		next unless($death);
		next if($death->{error});

		my $bcountry = $birth->{'country'} || $birth->{'address'}{'country'};
		my $dcountry = $death->{'country'} || $death->{'address'}{'country'};

		if($dcountry ne $bcountry) {
			push @emmigrants, $person;
		}
	}

	# TODO: handle situation where look up fails
	return $self->SUPER::html({ emmigrants => \@emmigrants, updated => $people->updated() });
}

1;
