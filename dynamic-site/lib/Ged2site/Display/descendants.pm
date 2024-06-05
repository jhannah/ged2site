package Ged2site::Display::descendants;

use strict;
use warnings;

# Display a person's descendants

use Ged2site::Display;

our @ISA = ('Ged2site::Display');

sub html {
	my $self = shift;
	my %args = (ref($_[0]) eq 'HASH') ? %{$_[0]} : @_;

	my $info = $self->{_info};
	my $allowed = {
		'page' => 'descendants',
		'entry' => qr/^[PI]\d+$/,
		'lang' => qr/^[A-Z][A-Z]/i,
		'lint_content' => qr/^\d$/,
	};
	my %params = %{$info->params({ allow => $allowed })};

	delete $params{'page'};
	delete $params{'lint_content'};
	delete $params{'lang'};

	my $people = $args{'people'};	# Handle into the database

	unless(scalar(keys %params)) {
		# Display the main index page
		return $self->SUPER::html(updated => $people->updated());
	}

	# Look in the people.csv for the name given as the CGI argument and
	# find their details
	# TODO: handle situation where look up fails
	my $person = $people->fetchrow_hashref(\%params);
	my ($nodes, $edges) = _build_nodes($people, $person, '0', 0);

	my $graph = "var graph = {\n" .
		"nodes: new vis.DataSet([\n" .
		$nodes .
		"]),\n" .
		"edges: new vis.DataSet([\n" .
		$edges .
		"])\n" .
		"};";

	return $self->SUPER::html({
		graph => $graph,
		person => $person,
		updated => $people->updated()
	});
}

sub _build_nodes {
	my $people = shift;
	my $person = shift;
	my $id = shift;
	my $level = shift;

	my $title = $person->{'title'};
	$title =~ s/\sc?(\w{3}\s)?\d{4}.+//;      # Remove dates
	if($title =~ /(.+)\s.+\s\(n&eacute;e\s(.+)\)/) {
		$title = "$1 $2";	# Get maiden name
	}
	if($title =~ /(.+)\s.+\s(.+)/) {
		$title = "$1 $2";	# Remove middle name(s)
	}
	# See https://github.com/almende/vis/issues/2975
	my $bio = $person->{'bio'};
	if($person->{'profile_thumbnail'}) {
		$bio = '<img src="/' . $person->{'profile_thumbnail'} . "\"><p><h2>$title</h2><hr>$bio";
	}
	$bio =~ s/"/\\"/g;
	# my $nodes = "{\"id\": \"$id\", \"label\": \"$title\", \"level\": $level, \"title\": \"$bio\" },\n";
	my $entry = $person->{'entry'};
	my $nodes = "{\"id\": \"$id\", \"label\": \"$title\", \"level\": $level, \"title\": \"$bio\", \"URL\": \"/cgi-bin/page.fcgi?page=people&entry=$entry\" },\n";
	my $count = 1;
	my $edges = '';

	if($person->{'children'}) {
		$level++;
		foreach my $child(split(/----/ ,$person->{'children'})) {
			if($child =~ /entry=([PI]\d+)">.+<\/a>/) {
				$child = $people->fetchrow_hashref({ entry => $1 });
				next if($child->{'alive'});

				my ($n, $e) = _build_nodes($people, $child, "$id." . $count, $level);
				$nodes .= $n;
				$edges .= "{\"from\": \"$id\", \"to\": \"$id.$count\"},\n" . $e;

				$count++;
			}
		}
	}

	return ($nodes, $edges);
}

1;
