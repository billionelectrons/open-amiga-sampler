$fa = 1;
$fs = 0.4;

use <MCAD/boxes.scad>

db25Width = 41;

boxRadius = 4;
boxWidth = 54;//db25Width + boxRadius * 2 + 2;
boxHeight = 19;
boxDepth = 65.5;
boxWallThickness = 2;
lipGap = 0.4;
wedgeChunkiness = 3.0;
wedgeProtrusion = 2.0;
pcbThickness = 1.6;

module outerShell() {
    roundedBox(size = [boxWidth, boxDepth, boxHeight], radius = boxRadius, sidesonly = false);
}

module innerShell() {
    roundedBox(size = [ boxWidth - boxWallThickness * 2, 
                        boxDepth - boxWallThickness * 2, 
                        boxHeight - boxWallThickness * 2],
                        radius = boxRadius - boxWallThickness, sidesonly = false);
}

module fullOuterCase() {
    difference () {
        difference () {
            difference() {
                outerShell();
                innerShell();
            }

            // DB25 hole
            translate([0, -(boxDepth - boxWallThickness) / 2, 0])
                rotate([90, 0, 0])
                    roundedBox(size = [db25Width, 10.5, boxWallThickness + 1], radius = 1, sidesonly = true);
        }
    }
}

module pcb() {
    difference() {
        cube([37.5, 34.0, pcbThickness], center = true);
        union() {
            translate([-37.5 * 0.5 + 2.5, 34.0 * 0.5 - 2.5, 0.0])
                cylinder(h = pcbThickness + 2, r = 2.25 * 0.5, center = true);
            translate([37.5 * 0.5 - 2.5, 34.0 * 0.5 - 2.5, 0.0])
                cylinder(h = pcbThickness + 2, r = 2.25 * 0.5, center = true);
        }
    }
}

module screwParts(top, subtract) {
    screwThreadRadius = 1.0;
    screwHeadRadius = 2.5;
    screwClearance = 0.4;
    
    for (x = [-16, 16])
        translate([x, -boxDepth * 0.5 + 37, 0]) {
            if (top == false) {
                if (subtract == false) {
                    translate([0, 0, boxHeight * 0.5 - epsilon])
                        rotate([180, 0, 0])
                            cylinder(r = screwHeadRadius + boxWallThickness, screwHeadRadius - (screwThreadRadius - screwClearance));
                    translate([0, 0, pcbThickness * 0.5 - epsilon])
                        cylinder(r = screwThreadRadius + screwClearance + boxWallThickness, h = (boxHeight - pcbThickness) * 0.5);
                }
                else {
                    translate([0, 0, boxHeight * 0.5 + epsilon])
                        rotate([180, 0, 0]) {
                        // Countersink
                            cylinder(r1 = screwHeadRadius, r2 = screwThreadRadius + screwClearance, h = screwHeadRadius - (screwThreadRadius + screwClearance));
                            // Hole
                            cylinder(r = screwThreadRadius + screwClearance, h = boxHeight * 0.5);
                    }
                }
            }
           
            if (top == true) {
                if (subtract == false) {
                    difference() {
                        translate([0, 0, pcbThickness * 0.5])
                            cylinder(r = screwThreadRadius + boxWallThickness, h = (boxHeight - pcbThickness) * 0.5 - boxWallThickness + epsilon);
                        cylinder(r = screwThreadRadius - 0.125, h = (boxHeight - pcbThickness) * 0.5 - boxWallThickness);
                    }
                }
            }
        }
}

epsilon = 0.001;

module connectorPanel(top, subtract) {
    curveRadius = 1.25;

    if ((top == true && subtract == false) || (top == false && subtract == true)) {
        union() {
            // Inner
            size0 = (top ? (boxWallThickness - lipGap) : (boxWallThickness + lipGap));
            translate([0, boxDepth * 0.5 - boxWallThickness + size0 * 0.25, 0]) {
                rotate([90, 0, 0])
                    roundedBox(size = [
                            boxWidth - boxRadius * 2 - curveRadius * 2.0 - (top ? lipGap * 2.0 : 0),
                            boxHeight - boxRadius * 2 - (top ? lipGap * 2.0 : 0),
                            size0 * 0.5 + (subtract ? epsilon : 0)
                        ],
                        sidesonly = true,
                        radius = curveRadius - (top ? lipGap : 0));

                for (a = [0, 180])
                    rotate([(top ? 0 : 180), 0, a]) {
                    x = -boxWidth * 0.5 + boxRadius + (top ? lipGap : 0);
                    z = -(boxWallThickness * 0.5 - (top ? lipGap : 0));
                    
                    difference() {
                        translate([ x + curveRadius * 0.5,
                                    0,
                                    z - curveRadius * 0.5])
                            cube([curveRadius + epsilon, size0 * 0.5 + epsilon, curveRadius + epsilon], center = true);
                        translate([x, 0, z - curveRadius])
                            rotate([90, 0, 0])
                                cylinder(r = curveRadius, h = size0 * 0.5 + 1.0, center = true);
                        
                    }
                }
            }
            
            // Outer
            size1 = (top ? (boxWallThickness + lipGap)  : (boxWallThickness - lipGap));
            translate([0, boxDepth * 0.5 - size1 * 0.25, 0]) {
                rotate([90, 0, 0])
                    roundedBox(size = [
                            boxWidth - boxRadius * 2 - boxWallThickness - curveRadius * 2.0 - (top ? lipGap : 0),
                            boxHeight - boxRadius * 2 - boxWallThickness - (top ? lipGap : 0),
                            size1 * 0.5 + (subtract ? epsilon : 0)
                        ],
                        sidesonly = true,
                        radius = curveRadius - boxWallThickness * 0.5);
                for (a = [0, 180])
                    rotate([(top ? 0 : 180), 0, a])
                        difference() {
                            x = -boxWidth * 0.5 + boxRadius + (top ? lipGap * 0.5 : 0);
                            translate([x + curveRadius + lipGap, 0, -curveRadius * 0.5])
                                cube([curveRadius, size1 * 0.5 + epsilon, curveRadius + epsilon], center = true);
                            translate([x + boxWallThickness * 0.5, 0, -curveRadius])
                                rotate([90, 0, 0])
                                    cylinder(r = curveRadius, h = size1 * 0.5 + 1.0, center = true);
                        }            
            }
        }
    }
    
    if (top == true && subtract == true) {
        // Phono hole
        for (x = [-14, 14])
            translate([x, (boxDepth - boxWallThickness) * 0.5, 0])
                rotate([90, 0, 0])
                    cylinder(r = 3.5, h = boxWallThickness + 0.01, center = true);
    }
}

module top() {
    potHoleHeight = boxWallThickness * 2.0;
    
    difference() {
        union() {
            difference() {
                union() {
                    difference() {
                        fullOuterCase();
                        union() {
                            translate([0, 0, -boxHeight * 0.5])
                                cube([boxWidth + 1, boxDepth + 1, boxHeight], center = true);
                            innerShell();
                        }
                    }
                    intersection() {
                        translate([0, 0, lipGap])
                            roundedBox(size = [
                                    boxWidth - (boxWallThickness + lipGap),
                                    boxDepth - (boxWallThickness + lipGap),
                                    boxWallThickness
                                ],
                                radius = boxRadius * 0.5 + (boxWallThickness - lipGap) * 0.5,
                                sidesonly = true);
                        fullOuterCase();
                    }
                    screwParts(top = true, subtract = false);
                    // Pot hole spacer
                    translate([0, boxDepth * 0.5 - boxRadius - 12.5, boxHeight * 0.5 - potHoleHeight * 0.5 - epsilon])
                        cylinder(h = potHoleHeight, r = 3.75 + 3.0, center = true);
                }
                union() {
                    // Pot hole
                    translate([0, boxDepth * 0.5 - boxRadius - 12.5, boxHeight  * 0.5 - potHoleHeight * 0.5])
                        cylinder(h = potHoleHeight + 0.01, r = 3.75, center = true);
                        screwParts(top = true, subtract = true);
                }
            }
            intersection() {
                union() {
                    connectorPanel(top = true, subtract = false);
                }
                outerShell();
            }
        }
        connectorPanel(top = true, subtract = true);
    }
}

module bottom() {
    rotate([0, 180, 0])
    union() {
        difference() {
            union() {
                union() {
                    difference() {
                        fullOuterCase();
                        union() {
                            translate([0, 0, -(boxHeight + 1) * 0.5])
                                cube([boxWidth + 1, boxDepth + 1, boxHeight + 1], center = true);
                            roundedBox(size = [
                                    boxWidth - (boxWallThickness - lipGap),
                                    boxDepth - (boxWallThickness - lipGap),
                                    boxWallThickness
                                ],
                                radius = boxRadius - (boxWallThickness - lipGap) * 0.5,
                                sidesonly = true);
                            innerShell();
                        }
                    }
                    screwParts(top = false, subtract = false);
                }
            }
            union() {
                connectorPanel(top = false, subtract = true);
                screwParts(top = false, subtract = true);
            }
        }
    }
}


if (true) {
    translate([-(boxWidth * 0.5 + 2), 0, 0])
        rotate([0, 180, 0]) {
            color("red")
            top();
            //translate([0, -boxDepth * 0.25 + 2.5, 0])
            //    pcb();
        }

    translate([(boxWidth * 0.5 + 2), 0, 0])
        color("blue")
        bottom();
}
else {
    translate([0, 0, 0])
    color("red")
    top();
    translate([0, 0, 0])
    color("blue")
    bottom();
}


/*
translate([0, 0, 0])
    color("blue")
    bottom();
*/

/*
rotate([0, 180, 0])
translate([0, 0, 0])
color("red")
top();
*/




