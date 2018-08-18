// HEX CELL CAPS V1.5
// This script generates models of cell holders and caps for 
// building battery packs using cylindrical cells. 
// Original concept by ES user "SpinningMagnets"
// More info can be found here:
// https://endless-sphere.com/forums/viewtopic.php?f=3&t=90058
//
// This file was created by Addy and is released as public domain
// Contributors
// Albert Phan


// TODO: 
// - add flat border option
// - add boxes


// CONFIGURATION

opening_dia = 12;   // Circular opening to expose cell 
cell_dia = 18.6;    // Cell diameter
wall = 0.8;           // Wall thickness around a single cell. Spacing between cells is twice this amount.

holder_height = 15; // Total height of cell holder
separation = 1;   	// Separation between cell top and tab slots
slot_height = 3.5;  // Height of all slots (3.5 mm is a good size for 14 awg solid in slots)
col_slot_width = 4; // Width of slots between rows
row_slot_width = 8; // Width of slots along rows

pack_style = "rect";    // "rect" for rectangular pack, "para" for parallelogram
wire_style = "strip";    // "strip" to make space to run nickel strips between cells. "bus" to make space for bus wires between rows
part_type = "normal";    // "normal","mirrored", or "both"  You'll want a mirrored piece if the tops and bottom are different ( ie. When there are even rows in rectangular style or any # of rows in parallelogram)
part = "box lid";   // "holder" to generate cell holders, "cap" to generate pack end caps, "box lid" to generate boxes for the holders to fit in

cap_wall = 1.2;
cap_clearance = 0.8;

box_wall = 2.0;
box_lid_height = 20;
box_clearance = 0.4;
wire_hole_width = 15;
wire_hole_height = 10;
wire_hole_length = 5;
wire_wall = 3;
wire_clearance = 20; 	// Space for wires above and below holders

num_rows = 3;       
num_cols = 4;

//////////////////////////////////////////////////////
// Don't forget to do a test fit print
//////////////////////////////////////////////////////

// END OF CONFIGURATION

$fn = 50;       // Number of facets for circular parts.  
extra = 0.1;    // enlarge hexes by this to make them overlap
spacing = 4;    // Spacing between top and bottom pieces
height_18650 = 65;

hex_w = cell_dia + 2*wall;	// Width of one hex cell
hex_pt = (hex_w/2 + extra) / cos(30); // Half the distance of point to point of a hex aka radius


if (part_type == "mirrored")
{
    if (part == "cap")
    {    
        mirror([1,0,0])
            regular_cap();
    }
    else if (part == "holder")    
    {
        mirror([1,0,0])
            regular_pack();
    }
}
else if(part_type == "both")
{
    if (part == "cap")
	{
        regular_cap();
	}
    else if (part == "holder")
        regular_pack();
    
    if(num_rows % 2 == 1)   // If odd pack move pack over to nest properly
    {

        mirror([1,0,0])
		{
            if (part == "cap")
                translate([-hex_w*(num_cols - 0.5), 1.5*(hex_pt-extra)*(num_rows+1) + spacing,0])
                    regular_cap();
            else if (part == "holder")
                translate([-hex_w*(num_cols - 0.5), 1.5*(hex_pt-extra)*num_rows + spacing,0])
                    regular_pack();
		}
    }
    else
    {
        
        mirror([1,0,0])
            if (part == "cap")
                translate([-hex_w*(num_cols - 0.5),1.5*(hex_pt-extra)*(num_rows+1) + spacing,0])
                    regular_cap();
			
            else if (part == "holder")
                translate([-hex_w*(num_cols - 1),1.5*(hex_pt-extra)*num_rows + spacing,0])
                    regular_pack();
    }
}
else	// if Normal
{
    if (part == "cap")  
	{
        regular_cap();
	}
    
    else if (part == "holder")
        regular_pack();
	else if (part == "box lid")
		regular_box_lid();
	// add box*-

}


// echos and info
echo(total_width=1.5*(hex_pt-extra)*(num_rows-1)+hex_pt*2);

if (pack_style == "rect")
{
    // Rectangular style
    echo(total_length=hex_w*(num_cols+0.5));
	if((num_rows % 2) == 0) // Even?
		
    echo("\n******************************************************* \n Top and bottom are different. Don't forget to do a mirrored part\n*******************************************************");
}
else if(pack_style == "para")
{
	// Parallelogram style
    echo(total_length=hex_w*(num_cols+0.5*(num_rows-1)));
	echo("\n******************************************************* \n Top and bottom are different. Don't forget to do a mirrored part\n*******************************************************");
}

// para cap needs to be fixed. It's thin on one side.
module para_cap()
{
    translate([-cap_clearance,-cap_clearance,-holder_height/2])
        difference()
        {
            
            translate([-cap_clearance/2,-cap_clearance/2,-(cap_wall)])
                minkowski()
                {

                    linear_extrude(height=extra + cap_wall, center=false, convexity=10)
                        polygon([
                            [0,0],
                            [hex_w*(num_rows-1)*0.5,1.5*(hex_pt-extra)*(num_rows-1)],
                            [hex_w*(num_rows-1)*0.5+hex_w*(num_cols-1),1.5*(hex_pt-extra)*(num_rows-1)],
                            [hex_w*(num_cols-1),0]]
                        );
                    
                    hex_pt2 = (hex_w/2 + extra + cap_clearance + cap_wall) / cos(30);
                    linear_extrude(height=holder_height, center=true, convexity=10)
                        polygon([ for (a=[0:5])[hex_pt2*sin(a*60),hex_pt2*cos(a*60)]]); 
                }    
            
            minkowski()
            {
                linear_extrude(height=extra*2, center=false, convexity=10)
                    polygon([
                        [0,0],
                        [hex_w*(num_rows-1)*0.5,1.5*(hex_pt-extra)*(num_rows-1)],
                        [hex_w*(num_rows-1)*0.5+hex_w*(num_cols-1),1.5*(hex_pt-extra)*(num_rows-1)],
                        [hex_w*(num_cols-1),0]]
                    );
                hex_pt2 = (hex_w/2 + extra + cap_clearance) / cos(30);
                linear_extrude(height=holder_height, center=true, convexity=10)
                    polygon([ for (a=[0:5])[hex_pt2*sin(a*60),hex_pt2*cos(a*60)]]); 
            }
                
        }
}


module rect_cap()
{
    translate([-cap_clearance,-cap_clearance,-holder_height])
        difference()
        {
            translate([-(cap_wall),-(cap_wall),-(cap_wall)])
                minkowski()
                {
                    translate([0,0,holder_height/2])
                        cube([(num_cols-0.5)*hex_w+2*(cap_wall+cap_clearance),
					1.5*(hex_pt-extra)*(num_rows-1)+2*(cap_wall+cap_clearance),
					extra+cap_wall],center=false);
                    
                   linear_extrude(height=holder_height, center=true, convexity=10)
                        polygon([ for (a=[0:5])[hex_pt*sin(a*60),hex_pt*cos(a*60)]]); 
                }        
            
            minkowski()
            {
                translate([0,0,holder_height/2])
                    cube([(num_cols-0.5)*hex_w+2*cap_clearance,1.5*(hex_pt-extra)*(num_rows-1)+2*cap_clearance,extra],center=false);
                
                linear_extrude(height=holder_height + extra, center=true, convexity=10)
                    polygon([ for (a=[0:5])[hex_pt*sin(a*60),hex_pt*cos(a*60)]]); 
            }
        }
} 


module regular_cap()
{
    if (pack_style == "rect")
        rect_cap();
    else if (pack_style == "para")
        para_cap();
}

module regular_box_lid()
{
	/* To do: decide on hole design for the wires
	just one hole in corner
	add support for wire hole
	add ghost image of the entire pack for debugging
	add zip ties to secure the two halves 
		support for zipties inbetween hex in shape of hex
		cutout ziptie area for flushness of ziptie
	
	add clearance for wires top and bottom
	add helper functions to get pack sizes 
	optimize using hull()
	
	
	*/
	
	
	
	
	if (pack_style == "rect")
	{
		translate([-box_clearance,-box_clearance,-holder_height + box_lid_height/2])
		{
			union()
			{
				
				difference()
				{
					union()
					{
					translate([-(box_wall),-(box_wall),-(box_wall)])
						// Positive minkowski
						minkowski()
						{
							translate([0,0,0])
								cube([(num_cols-0.5)*hex_w+2*(box_wall+box_clearance),1.5*(hex_pt-extra)*(num_rows-1)+2*(box_wall+box_clearance),extra],center=false);
							
							linear_extrude(height=box_lid_height, center=true, convexity=10)
								polygon([ for (a=[0:5])[hex_pt*sin(a*60),hex_pt*cos(a*60)]]); 
						} 		
					// Wire support hole
					translate([(num_cols)*hex_w + box_clearance + box_wall * 1.5 - wire_hole_length*8/2,box_wall,-box_wall + extra/2])
								cube([wire_hole_length*10,wire_hole_width + wire_wall *2,wire_hole_height+extra], center = true);
						
					}
					// Negative minkowski
					minkowski()
					{
						translate([0,0,0])
							cube([(num_cols-0.5)*hex_w+2*box_clearance,1.5*(hex_pt-extra)*(num_rows-1)+2*box_clearance,extra],center=false);
						
						linear_extrude(height=box_lid_height, center=true, convexity=10)
							polygon([ for (a=[0:5])[hex_pt*sin(a*60),hex_pt*cos(a*60)]]); 
					}
					
					// Wire hole cutout
					translate([(num_cols)*hex_w+box_clearance+box_wall *1.5,box_wall,extra])
					cube([wire_hole_length *11 + box_wall *3,wire_hole_width,wire_hole_height+extra], center = true);
				}
				// Ziptie supports
					for(col=[1:num_cols])
					{
						// iterate on one side
						// add support in the shape of a hex inbetween cols
						difference()
						{
						translate([-hex_w/2 + col * hex_w + box_clearance,-hex_pt*1.5 - box_clearance/2,-box_wall - box_lid_height/2])
							linear_extrude(height=box_lid_height + extra, center=false, convexity=10)
								polygon([ for (a=[0:5])[hex_pt*sin(a*60),hex_pt*cos(a*60)]]);
						
						translate([-hex_w/2 + col * hex_w + box_clearance,-hex_pt*2 - box_wall + extra,-box_wall - box_lid_height/2 -extra])
						{
							cube([hex_pt*2 + extra,hex_pt*2,box_lid_height*5],center = true);
							
							
						}

					
						}


					}
					// Add cutout for last support piece
					// Fix z translate and cube sizes
					translate([-hex_w/2 + num_cols * hex_w + box_clearance - hex_pt,0,-holder_height +box_lid_height/2 -box_wall - box_lid_height/2])
					{
						#cube([hex_w*2, hex_pt *2, box_lid_height+extra*3]);
					}
			}
				
		}
		%regular_pack();	// for debugging for now
	}
	
    else if (pack_style == "para")
    // para box;
	;
	
}


module regular_pack()
{
    union()
    {
        for(row = [0:num_rows-1])
        {
            
            if (pack_style == "rect")
            {
                if ((row % 2) == 0)
                {            
                    translate([0,1.5*(hex_pt-extra)*row,0])
                    for(col = [0:num_cols-1])
                    {
                        translate([hex_w*col,0,0])
                            pick_hex();
                    }                
                }
                else
                {
                    translate([0.5 * hex_w,1.5*(hex_pt-extra)*row,0])
                    for(col = [0:num_cols-1])
                    {
                        translate([hex_w*col,0,0])
                            pick_hex();
                    }
                }
            }
            else if (pack_style == "para")
            {
                translate([row*(0.5 * hex_w),1.5*(hex_pt-extra)*row,0])
                for(col = [0:num_cols-1])
                {
                    translate([hex_w*col,0,0])
                        pick_hex();
                }

            }
        }
    }      
}


module pick_hex()
{
    if (wire_style == "strip")
        strip_hex();
    else if (wire_style == "bus")
	{
        bus_hex();
	}
    else
        strip_hex();
}


module strip_hex()
{
	mirror([0,0,1])
	{
		difference()
		{
			// Hex block
			linear_extrude(height=holder_height, center=false, convexity=10)
				polygon([ for (a=[0:5])[hex_pt*sin(a*60),hex_pt*cos(a*60)]]); 
					
			// Top opening    
			translate([0,0,-1])
				cylinder(h=holder_height+2,d=opening_dia);
			  
			// Cell space    
			//#translate([0,0,-holder_height])
				//cylinder(h=2*(holder_height-slot_height),d=cell_dia);
				cylinder(h=2 *(holder_height-slot_height-separation) ,d=cell_dia, center=true);
			
			// 1st column slot
			rotate([0,0,60])
				translate([0,0,holder_height])    
					cube([hex_w+1,col_slot_width,2*slot_height], center=true);    
				
			// 2nd column slot
			rotate([0,0,-60])
				translate([0,0,holder_height])    
					cube([hex_w+1,col_slot_width,2*slot_height], center=true);
		   
			// Row slot 
			translate([0,0,holder_height]) 
				cube([hex_w+1,row_slot_width,2*slot_height], center=true);   
		}   
	}
}


module bus_hex()
{
	mirror([0,0,1])
	{
		difference()
		{
			// Hex block
			linear_extrude(height=holder_height, center=false, convexity=10)
				polygon([ for (a=[0:5])[hex_pt*sin(a*60),hex_pt*cos(a*60)]]); 
					
			// Top opening    
			translate([0,0,-1])
				cylinder(h=holder_height+2,d=opening_dia);
			  
			// Cell space    
			//#translate([0,0,-holder_height])
				//cylinder(h=2*(holder_height-slot_height),d=cell_dia);
				cylinder(h=2 *(holder_height-slot_height-separation) ,d=cell_dia, center=true);
			
			bus_width = (hex_pt + wall) - (opening_dia/2);    
				
			// 1st column slot
			rotate([0,0,60])
				translate([0,0,holder_height])    
					cube([hex_w+1,col_slot_width,2*slot_height], center=true);    
				
			// 2nd column slot    
			rotate([0,0,-60])
				translate([0,0,holder_height])    
					cube([hex_w+1,col_slot_width,2*slot_height], center=true);
					
			// Row slot A
			translate([0,(opening_dia/2)+bus_width/2-wall,holder_height]) 
				cube([(2*hex_w)+extra,bus_width,2*slot_height], center=true);  
			  
			// Row slot B    
			translate([0,-((opening_dia/2)+bus_width/2-wall),holder_height]) 
				cube([(2*hex_w)+extra,bus_width,2*slot_height], center=true);              
			
			/*
			translate([0,0,holder_height]) 
				cube([hex_w+1,row_slot_width,2*slot_height], center=true);   
				*/
				
		}
	}	
}

