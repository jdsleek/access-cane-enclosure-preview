// ACCESS Devices 2 + 3: REDUCER HALF-SLEEVES for the existing enclosure-151 back collars (Directive 170, 2026-11-05)
// The box's own split collars (bore 22 mm CAD placeholder, 18 mm wide, 2 x M4 each) clamp the ~16.2 mm stick directly
// through two printed half-sleeves per collar. No post, no shoe, no stand-off, no box changes.
// Uses the EXISTING 4 x M4 collar screws per box (not the one-screw clamp).

part = "show";          // show_d2 | show_d3 | half_print | coupon_print | set_print | top
cane_od     = 16.2;     // fit-tested size (wrap clamp test passed 2026-11-05)
collar_bore = 22.0;     // ASSUMED from the 151 CAD (cane_d = 22); not measured on the physical backs
cw          = 18;       // collar width along the cane (151)
od_fit      = 0.2;      // sleeve OD = bore - od_fit (slides in; the collar closes on it)
id_fit      = 0.2;      // sleeve ID = cane + id_fit; ribs below make the grip
rib_h       = 0.3;      // 16 grip ribs inside (tips at cane - 0.2 dia)
split_gap   = 1.4;      // gap between the two halves on each side, so the collar can squeeze the sleeve
lip         = 1.4;      // retaining lips at both ends (stop the sleeve walking out of the collar)
lip_r       = 1.3;      // radial height of the lips
$fn = 96;

ro = (collar_bore - od_fit)/2;  ri = (cane_od + id_fit)/2;
L = cw + 2*lip + 0.4;           // 0.2 axial play each side

module half2d(){
  difference(){
    intersection(){ circle(r=ro); translate([-ro-1, split_gap/2]) square([2*ro+2, ro+1]); }
    circle(r=ri);
  }
  intersection(){                                          // grip ribs
    for (i = [0:7]) rotate(11.25 + i*22.5) translate([ri, 0]) circle(r=rib_h + 0.05, $fn=12);
    translate([-ro, split_gap/2]) square([2*ro, ro]);
  }
}
module lip2d(){ difference(){ intersection(){ circle(r=ro + lip_r); translate([-ro-lip_r-1, split_gap/2]) square([2*(ro+lip_r)+2, ro+lip_r+1]); } circle(r=ri); } }
module half(){                                               // printed upright (axis vertical), no supports
  linear_extrude(L) half2d();
  linear_extrude(lip) lip2d();                               // bottom lip on the bed
  translate([0,0,L - lip]) hull(){                           // top lip with a 45-degree underside (no overhang)
    linear_extrude(0.01) half2d_outer(ro);
    translate([0,0,lip_r]) linear_extrude(lip - lip_r) half2d_outer(ro + lip_r);
  }
}
module half2d_outer(r){ difference(){ intersection(){ circle(r=r); translate([-r-1, split_gap/2]) square([2*r+2, r+1]); } circle(r=ri); } }
module half_clean(){ difference(){ half(); translate([0,0,-1]) cylinder(r=ri - rib_h - 0.01, h=L + 2); } }

// ---------- previews in the 151 in-use frame (X across, Y up the cane, Z front 0 -> back; cane axis at (32, y, 48)) ----------
function Hb(v) = v == "four" ? 130 : 110;
module box(v){ color([0.12,0.12,0.13]) import(str("../ref151/", v, "/u_body.stl"));
  if (v == "four") color([0.12,0.12,0.13]) import("../ref151/four/u_nose.stl");
  color([0.22,0.22,0.24]) import(str("../ref151/", v, "/u_plate.stl"));
  color([0.3,0.3,0.32]) import(str("../ref151/", v, "/u_caps.stl")); }
module sleeves_on_box(v, ex=0){ for (y0 = [4, Hb(v) - 4 - cw]) translate([32, y0 - lip - 0.2, 48]) rotate([-90,0,0])
  for (s = [0, 1]) rotate([0,0,s*180 + 90]) translate([0, ex*(s ? -1 : 1), 0]) color("#e07a1f") half_clean(); }
module show(v, ex=0){ box(v); sleeves_on_box(v, ex); color([0.95,0.95,0.95]) translate([32, -60, 48]) rotate([-90,0,0]) cylinder(d=cane_od, h=Hb(v) + 120); }

if (part == "show_d2") show("two");
if (part == "show_d3") show("four");
if (part == "show_d3_exploded") show("four", 14);
if (part == "top") { color("#e07a1f") { half_clean(); rotate(180) half_clean(); } color([0.85,0.85,0.85]) translate([0,0,-1]) cylinder(d=cane_od, h=1); }
if (part == "half_print") half_clean();
if (part == "coupon_print") { half_clean(); translate([0, -(ro + 4), 0]) mirror([0,1,0]) half_clean(); }        // one collar = 2 halves
if (part == "set_print") for (i = [0:3]) translate([(i%2)*(2*ro + 8), floor(i/2)*(-(2*ro + 10)), 0]) half_clean();   // one device = 4 halves
if (part == "both_print") for (i = [0:7]) translate([(i%4)*(2*ro + 8), floor(i/4)*(-(2*ro + 10)), 0]) half_clean();   // Devices 2 + 3 = 8 halves
