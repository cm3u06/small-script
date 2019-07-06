#!/usr/bin/perl -w



sub get_compare_ppm_param {

	my ( $h, $w, $file ) = @_;

	open (FI, "< $file") or die $!;

	# 0x8c[3:1] : FLIP_RORATE_TYPE
	# 0x10 : L x str, end
	# 0x48 : R x str, end
	# 0x14 : y str, end
	# 0x0c : dst lr enable


	my %param;

	while (<FI>) {
		next if ($_ =~ /^\s*#/ or $_ =~ /^\s*$/ or $_ !~ /^\s*sw/ );

		$_ =~ /([[:xdigit:]]+)\s*,\s*32'h(\w+)/;

		my $ba = hex($1);
		my $val = hex($2);


		my $lx_str = 0;
		my $lx_end = 0;
		my $rx_str = 0;
		my $rx_end = 0;
		my $y_str = 0;
		my $y_end = 0;

		if ( $ba == 0x8c  ) {
			my $fr_type = ($val >> 1) & 7; # 3:1
			$param{"fr_type"} = $fr_type;
			$param{"vf"} = $fr_type==2 or $fr_type == 6;
			$param{"hf"} = $fr_type==2 or $fr_type == 4;
		}
		elsif ( $ba == 0x10 ) {
			$lx_str = $val & 0xffff;
			$lx_end = ( $val >> 16 ) & 0xffff;
		}
		elsif ( $ba == 0x48 ) {
			$rx_str = $val & 0xffff;
			$rx_end = ( $val >> 16 ) & 0xffff;
		}
		elsif ( $ba == 0x14 ) {
			$y_str = $val & 0xffff;
			$y_end = ( $val >> 16 ) & 0xffff;
		}


	}

	close FI;



	if ($fr_type == 0) {
		$param{"rys"} = $y_str;
		$param{"rxs"} = $lx_str;
	}
	elsif ($fr_type == 1) {
		$param{"rys"} = $lx_str;
		$param{"rxs"} = $h - $y_end - 1;
	}
	elsif ($fr_type == 2) {
		$param{"rys"} = $h - $y_end -1;
		$param{"rxs"} = $w - $rx_end - 1;
	}
	elsif ($fr_type == 3) {
		$param{"rys"} = $w - ( ( $lx_end - $lx_str + 1 ) + ( $rx_end - $rx_str + 1 ) );
		$param{"rxs"} = $y_str;
	}
	elsif ($fr_type == 4) {
		$param{"rys"} = $y_str;
		$param{"rxs"} = $w - ( ( $lx_end - $lx_str + 1 ) + ( $rx_end - $rx_str + 1 ) );
	}
	elsif ($fr_type == 5) {
		$param{"rys"} = $w - $rx_end - 1;
		$param{"rxs"} = $h - $y_end -1;
	}
	elsif ($fr_type == 6) {
		$param{"rys"} = $h - $y_end - 1;
		$param{"rxs"} = $lx_str;
	}
	elsif ($fr_type == 7) {
		$param{"rys"} = $lx_str;
		$param{"rxs"} = $y_str;
	}


	my $param_string ;
	$param_string .= "-$_ $param{$_} " for ( keys %param ) ;

	return $param_string;
	

	
}
