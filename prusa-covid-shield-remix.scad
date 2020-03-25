// -*- mode: scad; c-basic-offset: 2; indent-tabs-mode:nil -*-
// Incoroprating some feedback from local healthcare providers
//   * weight-reducing of front-part if possible.
//   * Move the shield buttons up so that there is material behind the openings
//     of the shield-punches

module orig_rc2() {
  // The distribted RC2 STL file is pretty shifted...
  translate([-844.5, 0, 0]) import("baseline/covid19_headband_rc2.stl", convexity=10);
}

module hole_punch(angle=0, r=6, from_bottom=2) {
  rotate([0, 0, angle]) translate([0, 70, from_bottom])
    rotate([-90, 0, 0]) cylinder(r=r, h=20, $fn=6);
}

module light_rc2() {
  angle_distance=11;  // degrees at which we punch our weight-reduce hole.
  difference() {
    orig_rc2();
    for (i = [-5:1:+5]) {
      // Punch holes exect in places of need of stabiliity.
      if (abs(i) != 2) hole_punch(i * angle_distance);
    }
  }
}

// section covering a shield pin. If 'above', we're cutting out the above part.
module shield_pin_cutout(above) {
  translate([0, 0, above ? +5 : -5]) cube([10, 15, 10], center=true);
}

module _cutout_block(angle, dist, above) {
  rotate([0, 0, angle]) translate([0, dist, 0]) shield_pin_cutout(above);
}

module cutout_block_above(angle, dist) { _cutout_block(angle, dist, true); }
module cutout_block_bottom(angle, dist) { _cutout_block(angle, dist, false); }

// The angle and distance the pins. We only need some rough position,
// as we just use this as a cut-out where we do the material-move operation.
// There we just move the bottom part up and replace the bottom part with
// what we found above (angles, positions determined empirically)
pin_angle_distances = [ [21.5, 80], [-21.5, 80], [76, 93], [-76, 93]];

module print_shield() {
  // Cut out the area with the pins and move them up.
  translate([0, 0, 7]) intersection() {
    light_rc2();
    for (x = pin_angle_distances) cutout_block_bottom(x[0], x[1]);
  }

  // Now cut out the area _above_ the pins and move them down.
  translate([0, 0, -10]) intersection() {
    light_rc2();
    for (x = pin_angle_distances) cutout_block_above(x[0], x[1]);
  }

  // Combine that with the shield, but leave out the original pin area which
  // is now replace with our construct above.
  difference() {
    light_rc2();
    for (x = pin_angle_distances) cutout_block_bottom(x[0], x[1]);
  }
}

// Places where we need support.
module support_modifier() {
  for (x = pin_angle_distances) cutout_block_bottom(x[0], x[1]);
}

//support_modifier();
print_shield();
