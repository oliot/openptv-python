#include "ptv.h"

int mouse_proc_c (int click_x, int click_y, int kind, int num_image)

{
  int     i, j, n, zf,  deletedummy;
  double  x, y, xa, ya;
  double  xa12, xb12, ya12, yb12;
  int     k, pt1, intx1, inty1, count, intx2, inty2, pt2;
  candidate cand[maxcand];
/*   Tk_PhotoHandle img_handle;
 *   Tk_PhotoImageBlock img_block;
 */
 
  if (zoom_f[0] == 1) {zf = 2;} else { zf = zoom_f[0];}

/*   click_x = atoi(argv[1]);
 *   click_y = atoi(argv[2]);
 */

  //n = atoi(argv[3]);
  n=num_image;
  //kind = atoi(argv[4]);
  if (examine)	zf *= 2;
// if (argc == 6 ) zf = atoi(argv[5]);
  
  switch (kind) 
    {

/* -------------------------- MIDDLE MOUSE BUTTON ---------------------------------- */

   

    case 3: /* generate epipolar line segments */
      
      /* get geometric coordinates of nearest point in img[n] */
      x = (float) (click_x - imx/2)/zoom_f[n] + zoom_x[n];
      y = (float) (click_y - imy/2)/zoom_f[n] + zoom_y[n];

      pixel_to_metric (x,y, imx,imy, pix_x,pix_y, &x,&y, chfield);
      x -= I[n].xh;	y -= I[n].yh;
      correct_brown_affin (x, y, ap[n], &x, &y);
      k = nearest_neighbour_geo (geo[n], num[n], x, y, 0.05);
      if (k == -999)
	{	  
	  printf  ("no point near click coord ! Click again!"); 
/* 	  Tcl_SetVar(interp, "tbuf", buf, TCL_GLOBAL_ONLY);
 * 	  Tcl_Eval(interp, ".text delete 2");
 * 	  Tcl_Eval(interp, ".text insert 2 $tbuf");
 */
	  return -1;
	}
      pt1 = geo[n][k].pnr;

      intx1 = (int) ( imx/2 + zoom_f[n] * (pix[n][pt1].x-zoom_x[n]));
      inty1 = (int) ( imy/2 + zoom_f[n] * (pix[n][pt1].y-zoom_y[n]));
    rclick_points_intx1=intx1;
    rclick_points_inty1=inty1;
    
      //drawcross (interp, intx1, inty1, cr_sz+2, n, "BlueViolet");

      printf ( "%d %d %d %d %d\n", pt1, pix[n][pt1].nx, pix[n][pt1].ny,
	       pix[n][pt1].n, pix[n][pt1].sumg);  
	       	       	       
	       for (i=0; i<n_img; i++)	 if (i != n)
		 {
		   /* calculate epipolar band in img[i] */
		   epi_mm (geo[n][k].x,geo[n][k].y,
			   Ex[n],I[n], G[n], Ex[i],I[i], G[i], mmp,
			   &xa12, &ya12, &xb12, &yb12);
		   
		   /* search candidate in img[i] */
		   printf("\ncandidates in img: %d\n", i);
		   find_candidate_plus_msg (geo[i], pix[i], num[i],
					    xa12, ya12, xb12, yb12, eps0,
					    pix[n][pt1].n, pix[n][pt1].nx, pix[n][pt1].ny,
					    pix[n][pt1].sumg, cand, &count, i);

		   distort_brown_affin (xa12,ya12, ap[i], &xa12,&ya12);
		   distort_brown_affin (xb12,yb12, ap[i], &xb12,&yb12);
		   xa12 += I[i].xh;	ya12 += I[i].yh;
		   xb12 += I[i].xh;	yb12 += I[i].yh;
		   metric_to_pixel (xa12, ya12, imx,imy, pix_x,pix_y,
				    &xa12, &ya12, chfield);
		   metric_to_pixel (xb12, yb12, imx,imy, pix_x,pix_y,
				    &xb12, &yb12, chfield);
		   intx1 = (int) ( imx/2 + zoom_f[i] * (xa12 - zoom_x[i]));
		   inty1 = (int) ( imy/2 + zoom_f[i] * (ya12 - zoom_y[i]));
		   intx2 = (int) ( imx/2 + zoom_f[i] * (xb12 - zoom_x[i]));
		   inty2 = (int) ( imy/2 + zoom_f[i] * (yb12 - zoom_y[i]));
           
           rclick_intx1[i]=intx1;
            rclick_inty1[i]=inty1;
            rclick_intx2[i]=intx2;
            rclick_inty2[i]=inty2;
	printf("intx1=%d\n",intx1);
printf("intx1=%d\n",inty1);
printf("intx2=%d\n",intx2);
printf("inty2=%d\n",inty2);

/*		   if ( n == 0 ) sprintf( val,"yellow");*/
/*		   if ( n == 1 ) sprintf( val,"green");*/
/*		   if ( n == 2 ) sprintf( val,"red");*/
/*		   if ( n == 3 ) sprintf( val,"blue");*/

		  // drawvector ( interp, intx1, inty1, intx2, inty2, 1, i, val);
            rclick_count[i]=count;
                   for (j=0; j<count; j++)
                     {
                       pt2 = cand[j].pnr;
                       intx2 = (int) ( imx/2 + zoom_f[i] * (pix[i][pt2].x - zoom_x[i]));
                       inty2 = (int) ( imy/2 + zoom_f[i] * (pix[i][pt2].y - zoom_y[i]));
                         rclick_points_x1[i][j]=intx2;
                         rclick_points_y1[i][j]=inty2;
                       //drawcross (interp, intx2, inty2, cr_sz+2, i, "orange");
                     }
   
		   
		 }

	       break;

	       	       
    case 4: /* delete points, which should not be used for orientation */

      
      j = kill_in_list (n, num[n], click_x, click_y);
      if (j != -1)
	{
	  num[n] -= 1;
	  printf ("point %d deleted", j);  
	 //Tcl_SetVar(interp, "tbuf", buf, TCL_GLOBAL_ONLY);
	  //Tcl_Eval(interp, ".text delete 2 2");
	  //Tcl_Eval(interp, ".text insert 2 $tbuf");
	}
      else {
	  printf ("no point near click coord !");  
	  //Tcl_SetVar(interp, "tbuf", buf, TCL_GLOBAL_ONLY);
	  //Tcl_Eval(interp, ".text delete 2 2");
	  //Tcl_Eval(interp, ".text insert 2 $tbuf");
      }
      break;


	  
/*------------------------ LEFT MOUSE BUTTON ------------------------------*/

/*    case 5: /* measure coordinates and grey value */

      /*x = (float) (click_x - imx/2)/zoom_f[n] + zoom_x[n];
      y = (float) (click_y - imy/2)/zoom_f[n] + zoom_y[n];

      sprintf (buf, "   %6.2f    %6.2f    %s", x, y, argv[5]); puts (buf);
      Tcl_SetVar(interp, "tbuf", buf, TCL_GLOBAL_ONLY);
      Tcl_Eval(interp, ".text delete 2");
      Tcl_Eval(interp, ".text insert 2 $tbuf");
      break;	       */
    }
  return 0;
}
