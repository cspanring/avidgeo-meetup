
/* color definitions */

@bg: #000;
@road: #fff;

/* fonts */

@light: "Helvetica Neue Light";

Map {
  background-color: #000;
}

/* layers */

.road {
  line-color: @road;
}


.building {
  ::outline {
    line-color: @road;
  }
  polygon-fill: @bg;
}

/* labels */

#roads[zoom>16] {
  text-name: "[street_nam]";
  text-face-name: @light;
  text-placement: line;
  text-fill: @road;
  text-halo-fill: @bg;
  text-halo-radius: 1.2;
  text-size: 12;
  text-character-spacing: 2;
  text-min-distance: 100;
  text-min-padding: 20;
  text-allow-overlap: false;
}
