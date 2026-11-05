// ACCESS Smart Cane - WRAP-AROUND HINGED CLAMP (2026-11-05: closes AROUND the stick from the side; no end access needed)
// Based on: ONE-SCREW SPLIT-C CANE CLAMP + DOVETAIL SHOE  (OPUS 2026-11-04, Founder Directive 165)
// Replaces the over-wide, shim-packed clamp seen in the Founder's fitting video (video NOT on this PC: not inspected).
//  * clamp: split-C collar, one wide continuous cradle (30 mm along the cane), ONE M3 screw across the split ears,
//    hex nut captured in the opposite ear (or heat-set insert), 1.8 mm split gap = clamping travel, textured bore or TPU liner.
//  * shoe: slides DOWN onto the clamp's dovetail rail, rests on the rail top (cap), a spring finger snaps under the rail
//    bottom (lock). Box/cradle comes off without touching the clamp: pull the finger tab outward, lift.
//  * The shoe bolts to the EXISTING printed catcher through its 2 x M4 arm holes (30 mm vertical pitch), or straps to a bare box.
// Frame: cane axis = Z (up toward the handle). Split/ears on -X (away from the box), rail on +X (toward the box).

// ======================= PARAMETERS =======================
part = "wrap_assembly";   // wrap_assembly | wrap_open | wrap_top | wrap_print | wrap_test_print | shoe_print | (old: assembly, clamp_print ...)
     // assembly | exploded | clamp_print | shoe_print | gauge_arcs | liner_print
CANE_OD_MM  = 13;      // UNMEASURED placeholder. Founder: calipers, or the gauge arcs (11..16). Telescopic white cane ~12-16.
liner_t     = 0;       // 0 = textured printed bore (default); 0.8-1.0 = TPU liner sleeve (print liner_print in TPU)
texture     = true;    // fine axial grip ribs in the bore (ignored when liner_t > 0)
bore_fit    = 0.4;     // diametral clearance before tightening (X1C holes print ~0.1-0.2 small); tune from the gauge arcs
split_gap   = 1.8;     // clamping travel at the split (Directive: 1.5-2)
clamp_len   = 30;      // continuous cradle length along the cane
ring_t      = 4.5;     // ring wall
fastener    = "nut";   // "nut" = M3 hex nut captured in the -Y ear | "insert" = M3 x 5.7 heat-set insert
m3_clear = 3.4; m3_head_d = 6.2; m3_nut_af = 5.65; m3_nut_t = 2.6; insert_d = 4.0; insert_len = 5.7;
// dovetail
rail_neck = 10; rail_top = 15; rail_h = 4.5; slide_clr = 0.25;
// shoe mounting to the existing catcher: M4 holes (catcher arm holes are 30 mm apart vertically)
shoe_hole_dz = 30; shoe_hole_y = 15; m4_clear = 4.5; m4_head_d = 8.6;
$fn = 72;

// ======================= DERIVED =======================
od  = CANE_OD_MM;
r_i = od/2 + liner_t + bore_fit/2;
r_o = r_i + ring_t;
ear_t = 6;                                   // each ear thickness (Y)
xs  = -(r_i + 4.2);                          // screw axis X: >= 2.5 mm of plastic between screw and bore (no screw on the cane)
ear_x = xs - 5.5;                            // ear outer end
zs  = clamp_len/2;                           // the ONE screw, mid-length
xr  = r_o + 1.5;                             // rail base plane
xp  = xr + rail_h + slide_clr;               // shoe slot ceiling
plate = 3.6;                                 // shoe back plate
shoe_z0 = -7; shoe_z1 = clamp_len + 0.2 + 3; // shoe extent (cap on top)
fin_w = 9; fin_len = 24; fin_t = 2.0;        // spring finger
assert(od >= 8 && od <= 30, "CANE_OD_MM out of range");

// ======================= HELPERS =======================
module rr(p, s, r=1.2){ translate(p) hull() for (x=[r, s[0]-r]) for (y=[r, s[1]-r]) translate([x,y,0]) cylinder(r=r, h=s[2], $fn=24); }
module ytear(x, z, y0, len, d){ translate([x, y0, z]) rotate([-90,0,0]) rotate([0,0,90]) linear_extrude(len) hull(){ circle(d=d); translate([-d/2*1.25,0]) square(0.3, center=true);} }  // horizontal hole, peak up (+Z)
module xtear(y, z, x0, len, d){ translate([x0, y, z]) rotate([0,90,0]) rotate([0,0,180]) linear_extrude(len) hull(){ circle(d=d); translate([d/2*1.25,0]) square(0.3, center=true);} }
module rail_profile(c=0){ polygon([[xr - 0.01 - c*0, -rail_neck/2 - c], [xr - 0.01, rail_neck/2 + c], [xr + rail_h + c, rail_top/2 + c], [xr + rail_h + c, -rail_top/2 - c]]); }

// ======================= CLAMP =======================
module clamp(){
  difference(){
    union(){
      cylinder(r=r_o, h=clamp_len);
      // ears (one block, split later) blended into the ring = rib against splitting at the ear root
      hull(){ translate([-r_i - 1, -(split_gap/2 + ear_t), 0]) cube([1, 2*(split_gap/2 + ear_t), clamp_len]);
              rr([ear_x, -(split_gap/2 + ear_t), 0], [3, 2*(split_gap/2 + ear_t), clamp_len], 1.5); }
      // rail pad + dovetail rail (along Z, full clamp length)
      hull(){ translate([r_i + 1, -rail_top/2 - 1, 0]) cube([1, rail_top + 2, clamp_len]); translate([xr - 0.5, -rail_top/2 - 1, 0]) cube([0.5, rail_top + 2, clamp_len]); }
      linear_extrude(clamp_len) rail_profile();
    }
    // bore
    translate([0,0,-1]) cylinder(r=r_i, h=clamp_len + 2);
    // split: slot from the bore out through the ears
    translate([ear_x - 1, -split_gap/2, -1]) cube([-ear_x + 1, split_gap, clamp_len + 2]);
    // the ONE M3 screw: clearance through both ears, head counterbore in +Y ear
    ytear(xs, zs, -(split_gap/2 + ear_t) - 1, 2*(split_gap/2 + ear_t) + 2, m3_clear);
    ytear(xs, zs, split_gap/2 + 3, ear_t, m3_head_d);
    if (fastener == "nut")
      translate([xs, -(split_gap/2 + ear_t) - 0.01, zs]) rotate([-90,0,0]) rotate([0,0,30]) cylinder(d=m3_nut_af/cos(30), h=m3_nut_t + 0.01, $fn=6);
    else
      ytear(xs, zs, -split_gap/2 - insert_len, insert_len + 0.01, insert_d);
    // soft entry chamfers on the bore ends (no sharp edge on the cane)
    for (z = [-0.01, clamp_len - 0.79]) translate([0,0,z]) cylinder(r1 = z < 1 ? r_i + 0.8 : r_i, r2 = z < 1 ? r_i : r_i + 0.8, h = 0.8);
    // lock notch is NOT needed: the shoe finger snaps under the rail bottom end
  }
  // grip texture: 18 fine axial ribs (0.35 high) that bite slightly when the screw closes the gap
  if (liner_t == 0 && texture)
    for (a = [10:20:350]) if (abs(a - 180) > 15) rotate(a) translate([r_i - 0.35, -0.3, 1.2]) cube([0.4, 0.6, clamp_len - 2.4]);
}

// ======================= SHOE (mates the rail, bolts to the catcher) =======================
module shoe(){
  difference(){
    union(){
      // slot body around the rail
      rr([xr + 0.3, -rail_top/2 - 4, shoe_z0], [xp + plate - xr - 0.3, rail_top + 8, shoe_z1 - shoe_z0], 1.5);
      // mounting wings (back plate), wide for the 2 bolts / strap
      rr([xp, -shoe_hole_y - 7, shoe_z0], [plate, 2*shoe_hole_y + 14, shoe_z1 - shoe_z0], 2);
    }
    // dovetail slot: open at the bottom, closed by the cap at the top (cap rests on the rail top = carries the weight)
    translate([0,0,shoe_z0 - 1]) linear_extrude(clamp_len + 0.2 - shoe_z0 + 1) rail_profile(slide_clr);
    translate([xr - 3, -rail_top/2 - 4.5, shoe_z0 - 1]) cube([3.3, rail_top + 9, clamp_len + 0.2 - shoe_z0 + 1]);   // clear the rail pad
    // spring finger: U-cut through the plate around it, thinned from the outside so it can flex outward
    difference(){
      translate([xp - 1, -fin_w/2 - 1.2, shoe_z0 - 1]) cube([plate + 2, fin_w + 2.4, fin_len + 1]);
      translate([xp - 1, -fin_w/2, shoe_z0 - 2]) cube([plate + 2, fin_w, fin_len + 4]);
    }
    translate([xp + fin_t, -fin_w/2 - 0.01, shoe_z0 - 1]) cube([plate, fin_w + 0.02, fin_len + 1]);
    // 2 x M4 bolt holes (catcher arm hole pattern), counterbored from the slot side
    for (z = [clamp_len/2 - shoe_hole_dz/2, clamp_len/2 + shoe_hole_dz/2]) {
      xtear(shoe_hole_y, z, xp - 5, plate + 6, m4_clear);
      xtear(shoe_hole_y, z, xp - 5, 5 + 1.2, m4_head_d);
    }
    // strap slots on the other wing (20 mm hook-and-loop) for a bare V1 box
    translate([xp - 1, -shoe_hole_y - 2, clamp_len/2 - 11]) cube([plate + 2, 3.5, 22]);
  }
  // finger tooth: flat top locks under the rail bottom (z=0), ramp below lets the rail push past while sliding in
  translate([0, 0, 0]) hull(){
    translate([xp - 1.0, -fin_w/2 + 0.6, -0.3 - 0.01]) cube([1.0 + 0.01, fin_w - 1.2, 0.01]);
    translate([xp - 0.01, -fin_w/2 + 0.6, -0.3 - 2.4]) cube([0.02, fin_w - 1.2, 2.4]);
  }
  // pull tab ridges on the finger end (tactile: "pull out here, then lift")
  for (i = [0:1]) translate([xp + fin_t - 0.01, -fin_w/2 + 1, shoe_z0 + 1 + i*2.4]) cube([1.2, fin_w - 2, 1]);
}

// ======================= TPU LINER =======================
module liner(){ difference(){ cylinder(r=od/2 + liner_t, h=clamp_len); translate([0,0,-1]) cylinder(d=od, h=clamp_len+2);
  translate([-0.6, 0, -1]) cube([1.2, od, clamp_len + 2]); } }

// ======================= FIT GAUGE ARCS =======================
// C-arcs (~220 deg) 4 mm tall, labelled: press each onto the cane at the mount spot. The right size clicks on and
// does not rotate freely; one size smaller will not go on. Uses ~3 g PLA in total.
module arc(d){
  difference(){
    union(){
      cylinder(d=d + 3.2, h=4);
      translate([-d/2 - 1.6 - 7, -4, 0]) cube([8, 8, 2]);        // label tab
    }
    translate([0,0,-1]) cylinder(d=d + 0.2, h=6);
    rotate(-70) translate([0,0,-1]) linear_extrude(6) polygon([[0,0], [d*2*cos(0), d*2*sin(0)], [d*2*cos(70), d*2*sin(70)], [d*2*cos(140), d*2*sin(140)]]);
    translate([-d/2 - 1.6 - 3, 0, 2 - 0.6]) linear_extrude(1) text(str(d), size=4, halign="center", valign="center");
  }
}
module gauge_arcs(){ sizes = [11, 12, 13, 14, 15, 16]; for (i = [0:len(sizes)-1]) translate([(i%3)*34, floor(i/3)*30, 0]) arc(sizes[i]); }


// ======================= WRAP-AROUND HINGED CLAMP (2026-11-05) =======================
// Two half-shells. Hinge (-X): half B carries a round bar, half A's C-hook rides on it (slide together along the bar before fitting).
// Open like a jaw, put it AROUND the stick, close, ONE M3 screw (+X ears; head on B side, nut captured in A). Rail (to the shoe) on A at +Y.
wg      = 1.6;                       // closing gap at the ears (clamping travel)
w_ear_t = 7.5;                       // Founder 11-05: old clamp cracked at the screw hole -> heavy ears
w_xs    = r_o + 1.0;                 // screw axis X (outside the ring): >= 3.5 mm plastic to the bore
w_ear_x = w_xs + 7.5;                // 5.8 mm of plastic OUTSIDE the screw hole (was 3.3)
H       = [-(r_o + 6.2), 0];         // hinge axis
bar_r   = 2.2; hook_ri = bar_r + 0.4; hook_ro = hook_ri + 3.0;
w_E     = [-(r_o - 1.8), -(6.5)];    // where B's web meets B's ring
rib_h   = 0.3;
module hp(sign){ translate([-60, sign > 0 ? wg/2 : -60 - wg/2]) square([120, 60]); }   // half-plane y > wg/2 or y < -wg/2
module sector(a0, a1, r){ polygon(concat([[0,0]], [for (a = [a0:5:a1]) r*[cos(a), sin(a)]], [r*[cos(a1), sin(a1)]])); }
module ring2d(){ difference(){ circle(r=r_o); circle(r=r_i); } for (i = [0:15]) rotate(i*22.5 + 11.25) translate([r_i - rib_h + 0.35, 0]) circle(r=0.35, $fn=16); }
module ear2d(sign){ hull(){ translate([r_i + 1, sign > 0 ? wg/2 : -wg/2 - w_ear_t]) square([1, w_ear_t]);
                            translate([w_ear_x - 3, sign > 0 ? wg/2 : -wg/2 - w_ear_t]) offset(r=1.2) offset(delta=-1.2) square([3, w_ear_t]); } }
module bweb2d(){ hull(){ translate(H) circle(r=1.5); translate(w_E) circle(r=1.9); } }
module B2d(){ union(){ intersection(){ union(){ ring2d(); ear2d(-1); } hp(-1); }  translate(H) circle(r=bar_r); bweb2d(); } }
module hook2d(){ difference(){ translate(H) circle(r=hook_ro); translate(H) circle(r=hook_ri); translate(H) sector(-150, -5, 20); offset(r=0.45) bweb2d(); } }
module A2d(){ difference(){ union(){ intersection(){ union(){ ring2d(); ear2d(1); } hp(1); }
                hook2d();
                hull(){ translate(H + 4.1*[cos(50), sin(50)]) circle(r=1.5); translate([-(r_o - 1.6), 4.8]) circle(r=2.3); }
                // rail pad + dovetail rail at +Y
                hull(){ translate([-rail_top/2 - 1, r_i + 1]) square([rail_top + 2, 1]); translate([-rail_top/2 - 1, xr - 0.5]) square([rail_top + 2, 0.5]); }
                rotate(90) rail_profile(); }
              translate(H) circle(r=hook_ri); circle(r=r_i - rib_h); } }
module bore_chamfer(L){ translate([0,0,-0.01]) cylinder(r1=r_i + 0.8, r2=r_i - rib_h, h=0.8 + 0.01); translate([0,0,L - 0.8]) cylinder(r1=r_i - rib_h, r2=r_i + 0.8, h=0.8 + 0.01); }
module wrapA(L=clamp_len){ difference(){ linear_extrude(L) A2d(); bore_chamfer(L);
    ytear(w_xs, L/2, -1, wg/2 + w_ear_t + 2, m3_clear);
    translate([w_xs, wg/2 + w_ear_t - m3_nut_t - 0.3, L/2]) rotate([-90,0,0]) rotate([0,0,30]) cylinder(d=(m3_nut_af + 0.25)/cos(30), h=m3_nut_t + 1, $fn=6); } }
module wrapB(L=clamp_len){ difference(){ linear_extrude(L) B2d(); bore_chamfer(L);
    ytear(w_xs, L/2, -(wg/2 + w_ear_t) - 1, w_ear_t + 2, m3_clear); } }
module w_screw(L=clamp_len){ color("#ff2d2d"){ translate([w_xs, -(wg/2 + w_ear_t), L/2]) rotate([90,0,0]) cylinder(d=5.5, h=3); translate([w_xs, -(wg/2 + w_ear_t), L/2]) rotate([-90,0,0]) cylinder(d=3, h=16); } }
module w_rotB(a){ translate([H[0], H[1], 0]) rotate(a) translate([-H[0], -H[1], 0]) children(); }
module wrap_assembly(open=0, ex=0){
  rotate([0,0,-90]){ color("#2f3338") wrapA(); color("#4a6fa5") w_rotB(-open) wrapB(); if (open == 0) w_screw(); }
  color("#e07a1f") translate([ex, 0, ex*1.5]) shoe();
  ghost_cane();
  if (ex == 0 && open == 0) ghost_box();
}
if (part == "wrap_assembly") wrap_assembly();
if (part == "wrap_open") { rotate([0,0,-90]){ color("#2f3338") wrapA(); color("#4a6fa5") w_rotB(-55) wrapB(); } ghost_cane(); }
if (part == "wrap_top") { color("#2f3338") wrapA(); color("#4a6fa5") wrapB(); color([0.95,0.95,0.95]) translate([0,0,-1]) cylinder(d=od, h=1); }
if (part == "wrap_open_top") { color("#2f3338") wrapA(); color("#4a6fa5") w_rotB(-60) wrapB(); color([0.85,0.85,0.85]) translate([6, -18, -1]) cylinder(d=od, h=1); color("#e07a1f") translate([6, -31, -1]) linear_extrude(1) polygon([[-3,0],[3,0],[0,6]]); }
if (part == "wrap_print") { wrapA(); translate([0, -34, 0]) wrapB(); }
if (part == "wrap_test_print") { wrapA(14); translate([0, -34, 0]) wrapB(14); }
if (part == "check_wrap") intersection(){ linear_extrude(1) A2d(); linear_extrude(1) B2d(); }
if (part == "check_wrap_open") intersection(){ linear_extrude(1) A2d(); w_rotB(-55) linear_extrude(1) B2d(); }


// ======================= DEVICE 2 / DEVICE 3 ADAPTER (Directive 169) =======================
// Devices 2 and 3 = enclosure_151 prints (B "two" H=110, one HC-SR04; A "four" H=130, two HC-SR04). ASSUMED from the 151 CAD
// that Tope printed: the box holds the cane with TWO split collars on its back plate, bore 22 mm (placeholder, too big for the stick).
// Adapter = a 22 mm "dummy cane" post that the box's OWN collars clamp (existing M4 screws, no box changes) + the shoe that slides
// onto the wrap clamp's rail on the real stick.  Cane -> wrap clamp (ONE M3) -> rail -> shoe+post -> box collars (existing) -> box.
post_d   = 21.6;                     // 151 collar bore = 22.0 nominal (prints ~21.8); the 2 mm collar split closes ~0.6 more
w151 = 64; zc151 = 48;               // 151 in-use frame: box width, cane/collar axis z (BD 30 + zc 18)
shoe_top = clamp_len + 0.2 + 3; shoe_bot = -7; shoe_mid = (shoe_top + shoe_bot)/2;
Px = (xp + plate) + post_d/2 - 1.5; // post axis, fused 1.5 mm into the shoe back plate
function H151(v) = v == "four" ? 130 : 110;
module post_adapter(v){ Hb = H151(v); L = Hb - 4; z0 = shoe_mid - Hb/2 + 2;     // post spans box y 2..H-2 (collars at 4..22 and H-22..H-4)
  union(){
    shoe();
    translate([Px, 0, z0]) difference(){ cylinder(d=post_d, h=L, $fn=96);
      translate([0,0,-0.01]) difference(){ cylinder(d=post_d + 2, h=1); cylinder(d1=post_d - 1.6, d2=post_d + 0.4, h=1); }
      translate([0,0,L - 0.99]) difference(){ cylinder(d=post_d + 2, h=1); cylinder(d1=post_d + 0.4, d2=post_d - 1.6, h=1); } }
    hull(){ translate([xp + plate - 1.2, -9, shoe_bot]) cube([1.2, 18, shoe_top - shoe_bot]); translate([Px, 0, shoe_bot]) cylinder(d=post_d - 2, h=shoe_top - shoe_bot); }  // web
  } }
module box151(v, ex=0){ Hb = H151(v);   // existing device in 151 in-use coords -> this frame (box front faces +X, away from the cane)
  multmatrix([[0,0,-1, Px + zc151 + ex], [-1,0,0, w151/2], [0,1,0, shoe_mid - Hb/2], [0,0,0,1]]) {
    color([0.12,0.12,0.13]) import(str("../ref151/", v, "/u_body.stl"));
    if (v == "four") color([0.12,0.12,0.13]) import("../ref151/four/u_nose.stl");
    color([0.22,0.22,0.24]) import(str("../ref151/", v, "/u_plate.stl"));
    color([0.3,0.3,0.32]) translate([0, 0, ex > 0 ? 0 : 0]) import(str("../ref151/", v, "/u_caps.stl")); } }
module dev_assembly(v, ex=0){
  rotate([0,0,-90]){ color("#2f3338") wrapA(); color("#4a6fa5") wrapB(); w_screw(); }
  color("#e07a1f") translate([ex*0.6, 0, 0]) post_adapter(v);
  box151(v, ex*1.6);
  color([0.95,0.95,0.95]) translate([0,0,-120]) cylinder(d=od, h=300);
}
if (part == "d2_assembly") dev_assembly("two");
if (part == "d3_assembly") dev_assembly("four");
if (part == "d2_exploded") dev_assembly("two", 25);
if (part == "d3_exploded") dev_assembly("four", 25);
if (part == "adapter_D2_print") translate([-Px, 0, -(shoe_mid - 110/2 + 2)]) post_adapter("two");
if (part == "adapter_D3_print") translate([-Px, 0, -(shoe_mid - 130/2 + 2)]) post_adapter("four");
if (part == "check_d3") intersection(){ post_adapter("four"); box151("four"); }
if (part == "check_d2") intersection(){ post_adapter("two"); box151("two"); }
if (part == "check_d3_cane") intersection(){ box151("four"); translate([0,0,-120]) cylinder(d=od + 4, h=300); }

// ======================= GHOSTS + OUTPUT =======================
module ghost_screw(){ // the ONE screw, highlighted
  color("#ff2d2d") { translate([xs, split_gap/2 + 3 + 2.8, zs]) rotate([90,0,0]) cylinder(d=5.5, h=3); translate([xs, split_gap/2 + 3, zs]) rotate([90,0,0]) cylinder(d=3, h=10); }
  if (fastener == "nut") color("#c9c9c9") translate([xs, -(split_gap/2 + ear_t), zs]) rotate([-90,0,0]) cylinder(d=5.5/cos(30), h=2.4, $fn=6);
}
module ghost_cane(){ color([0.95,0.95,0.95]) translate([0,0,-80]) cylinder(d=od, h=200); }
module ghost_box(){ color([0.75,0.77,0.8,0.4]) translate([xp + plate, -45, -40]) cube([30, 80, 130]); }   // existing V1 box/catcher, envelope only
module assembly(ex=0){
  color("#2f3338") clamp(); ghost_screw();
  color("#e07a1f") translate([ex, 0, ex*1.5]) shoe();
  ghost_cane();
  if (ex == 0) ghost_box();
}
if (part == "assembly") assembly();
if (part == "exploded") assembly(18);
if (part == "clamp") clamp();
if (part == "shoe") shoe();
if (part == "clamp_print") clamp();                              // upright: bore vertical, screw hole teardrop, no supports
if (part == "shoe_print") translate([0,0,-shoe_z0]) shoe();      // upright on its bottom end, slot vertical, no supports
if (part == "gauge_arcs") gauge_arcs();
// ---- Directive 166 slot comb gauge: push the cane sideways into the U-slots; the narrowest slot it enters
//      without force = cane OD at that spot. No flexing parts. Slot width = nominal (X1C prints slots ~0.1 narrow).
comb_sizes = [14.5, 15, 15.5, 16, 16.5, 17, 17.5, 18, 18.5];
module slot_comb(){
  pitch = 23; t = 3; H = 23; wall = 4; n = len(comb_sizes); L = n*pitch;   // slot: semicircle + straight sides 'wall' mm up to the open edge
  difference(){
    rr([0, 0, 0], [L, H, t], 2);
    for (i = [0:n-1]) { d = comb_sizes[i]; cx = pitch/2 + i*pitch; cy = H - wall;
      translate([cx, cy, -1]) cylinder(d=d, h=t + 2, $fn=96);
      translate([cx - d/2, cy, -1]) cube([d, wall + 1, t + 2]);
      translate([cx, 4.2, t - 0.8]) linear_extrude(1) text(str(d), size=4.2, halign="center", valign="center", font="Liberation Sans:style=Bold");
    }
  }
}
if (part == "slot_comb") slot_comb();

if (part == "liner_print") liner();
if (part == "check_shoe_rail") intersection(){ clamp(); shoe(); }
if (part == "check_screw_bore") intersection(){ translate([0,0,-1]) cylinder(r=r_i + 0.5, h=clamp_len + 2); translate([xs, -20, zs]) rotate([-90,0,0]) cylinder(d=m3_clear + 2*0.5, h=40); }

echo(CANE_OD_MM=od, BORE_D=2*r_i, CLOSE_TRAVEL_D=split_gap/PI, GRIPS_DOWN_TO_OD=2*r_i - split_gap/PI - 2*liner_t,
     SCREW="ONE M3 x 10 socket/pan head" , SCREW_TO_BORE_WALL=-xs - m3_clear/2 - r_i, CLAMP_ENVELOPE=[xr + rail_h - ear_x, 2*(split_gap/2 + ear_t) > rail_top ? 2*(split_gap/2 + ear_t) : rail_top + 2, clamp_len]);
