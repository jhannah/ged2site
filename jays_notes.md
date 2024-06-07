
Had to force this one:

cpanm -v --notest Data::Throttler

Wow, Geo-Coder-Free-0.35 downloads tons of data, kept failing. I downloaded all its 
dependencies manually and installed it manually.

Won't install:

  cpanm -v Image::Magick

This worked:

  brew install imagemagick
  cpanm -v --notest Image::Magick

Had to run these:
  cpanm -v --notest Image::Magick::Thumbnail
  cpanm -v HTTP::Cache::Transparent

Try to run the whole thing:

  ./ged2site -cFdh 'Jay Weston Hannah' -l ~/Desktop/jay_new.ged

Minimal run:

  ./ged2site -cFdh 'Jay Weston Hannah' -lL 1 ~/Desktop/jay_new.ged

Data cleanup:

[====   4290 of ./ged2site                                   ]   7% [ 320/4182]
	1084 of ./ged2site
Date parse failure: left = (AFT. 1873) at ./ged2site line 12606, <GEN0> line 25430.
From:
  2 DATE AFT. 1873
Changed to
  2 DATE +1873/
Nope
  Date parse failure: left = (+1873/) at ./ged2site line 12597, <GEN0> line 25430.
Let's try this:
  2 DATE AFT 1873
  success!

Date parse failure: left = (aft 1873) at ./ged2site line 12606, <GEN0> line 25430.
^ hacked my way around that one for now
  https://github.com/nigelhorne/ged2site/issues/111

Data::Text: attempt to add consecutive punctuation           ]  36% [1529/4182]
	Current = 'The twin brother of Jane E. and the 2nd of 3 children of <a href="?page=people&entry=I2599">James Hamilton</a> and <a href="?page=people&entry=I2600">Myrtle Combs</a>, <b>Harry</b>is  the third cousin once-removed on the father's side of <a href="?page=people&home=1">Jay Hannah</a> and was born on Jul 25, 1933 along with his twin sister Jane E.' added at 3510 of ./ged2site
	Append = '.' at ./ged2site line 3510.
  
