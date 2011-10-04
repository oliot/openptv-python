import numpy as np
cimport numpy as np

cdef extern from "stdlib.h":
    void *memcpy(void *dst, void *src, long n)


cdef extern void highpass(unsigned char *img, unsigned char *img_hp, int dim_lp, int filter_hp, int field)
cdef extern int init_proc_c()
cdef extern int start_proc_c()
cdef extern int pre_processing_c ()
cdef extern int detection_proc_c() 
cdef extern int correspondences_proc_c() 
cdef extern int calibration_proc_c(int sel) 

cdef extern int sequence_proc_c(int dumb_flag)
cdef extern int sequence_proc_loop_c(int dumbell, int i)

cdef extern int trackcorr_c_init ()
cdef extern int trackcorr_c_loop (int step, double lmax, double Ymin, double Ymax, int display )
cdef extern int trackcorr_c_finish(int step)
cdef extern int trackback_c ()
cdef extern int trajectories_c(int i)
cdef extern void read_ascii_data(int filenumber)
cdef extern int determination_proc_c (int dumbbell)
cdef extern double lmax_track,ymin_track,ymax_track
cdef extern int seq_first, seq_last

cdef extern int mouse_proc_c (int click_x, int click_y, int kind, int num_image)

cdef extern int imgsize
cdef extern int imx
cdef extern int imy
cdef extern int dumbbell_pyptv
cdef extern int match4_g,match3_g,match2_g,match1_g
cdef extern unsigned char *img[4]
cdef extern int seq_step_shake

#cdef extern struct target

ctypedef extern struct target:
    int pnr
    double  x, y
    int     n, nx, ny, sumg
    int     tnr



ctypedef extern struct coord_2d:
    int pnr
    double x, y
    
ctypedef extern struct n_tupel:
    int     p[4]
    double  corr

cdef extern target *p[4]
cdef extern target *t4[4][4]
cdef extern int nt4[4][4]
cdef extern target pix[4][20240]
cdef extern coord_2d geo[4][20240]
cdef extern n_tupel con[20240] 
cdef extern int x_calib[4][1000]
cdef extern int y_calib[4][1000]
cdef extern int z_calib[4][1000]
cdef extern int ncal_points[4]  
cdef extern int  orient_x1[4][1000]
cdef extern int  orient_y1[4][1000]
cdef extern int  orient_x2[4][1000]
cdef extern int  orient_y2[4][1000]
cdef extern int  orient_n[4]    
cdef extern int intx0_tr[4][10000],intx1_tr[4][10000],intx2_tr[4][10000],inty0_tr[4][10000],inty1_tr[4][10000],inty2_tr[4][10000],pnr1_tr[4][10000],pnr2_tr[4][10000],m1_tr
cdef extern float pnr3_tr[4][10000]
cdef extern int n_img
cdef extern int num[4]
cdef extern int zoom_x[], zoom_y[], zoom_f[]
cdef extern int rclick_intx1[4],rclick_inty1[4],rclick_intx2[4],rclick_inty2[4], rclick_points_x1[4][10000],rclick_points_y1[4][10000],rclick_count[4]
cdef extern int rclick_points_intx1, rclick_points_inty1


def py_set_imgdimensions(size,imx1,imy1):
    global imgsize,imx,imy
    imgsize=<int>size
    imx=<int>imx1
    imy=<int>imy1

def py_highpass(np.ndarray img1, np.ndarray img2, dim_lp1, filter_lp1, field1 ):
    highpass(<unsigned char *>img1.data, <unsigned char *>img2.data, dim_lp1, filter_lp1, field1)
    

def py_set_img(np.ndarray img_one, i):
    global img

    cdef int img_size=img_one.size
    cdef unsigned char *img_dest=<unsigned char *>img_one.data
    cdef int i1=i
#   for i1 in range(50):
#       print("img0 ", img_dest[i1])
    memcpy(img[i],<unsigned char *>img_one.data,img_size*sizeof(unsigned char))

def py_get_img(np.ndarray img_one, i):
    global img, imgsize
    print ("img_size=",imgsize)
    #cdef int i1=i
    
    memcpy(img_one.data,img[i],imgsize*sizeof(unsigned char))
    cdef unsigned char *img_dest=<unsigned char *>img_one.data
    cdef int i1=i
    for i1 in range(50):
        print("img1 ", img_one[i1])


    
def py_start_proc_c():
    start_proc_c()
        
        
        
def py_init_proc_c():
    init_proc_c()  #initialize general globals 
    
def py_pre_processing_c():
    pre_processing_c()

def py_detection_proc_c():
    detection_proc_c()

def py_read_attributes(a):
    global imgsize, imx, imy
    a.append(imgsize)
    a.append(imx)
    a.append(imy)
    
def py_get_pix(x,y):
    global pix,n_img
    cdef int i,j
    for i in range(n_img):
        x1=[]
        y1=[]
        for j in range(num[i]):
            x1.append(pix[i][j].x)
            y1.append(pix[i][j].y)
        x.append(x1)
        y.append(y1)
    
def py_calibration(sel):
    calibration_proc_c(sel) 
    
def py_correspondences_proc_c(quadruplets,triplets,pairs, unused):
    global pix,n_img,match4_g,match3_g,match2_g,match1_g,geo,con,p

    correspondences_proc_c()
#  get quadruplets ---------------------------  
    cdef int i,j
    quadruplets_x=[]
    quadruplets_y=[]
    for j in range(n_img):
        x1=[]
        y1=[]
        for i in range (match4_g):
            p1 = geo[j][con[i].p[j]].pnr
            if (p1>-1):
                x1.append(pix[j][p1].x)
                y1.append(pix[j][p1].y)
        quadruplets_x.append(x1)
        quadruplets_y.append(y1)
    quadruplets.append(quadruplets_x)
    quadruplets.append(quadruplets_y)
# get triplets -----------------------------
    
    triplets_x=[]
    triplets_y=[]
    for j in range(n_img):
        x1=[]
        y1=[]
        for i in range (match4_g,match4_g+match3_g):
            p1 = geo[j][con[i].p[j]].pnr
            if (p1>-1 and con[i].p[j] > -1):
                x1.append(pix[j][p1].x)
                y1.append(pix[j][p1].y)
        triplets_x.append(x1)
        triplets_y.append(y1)
    triplets.append(triplets_x)
    triplets.append(triplets_y)
#get pairs -----------------------------------------

    pairs_x=[]
    pairs_y=[]
    for j in range(n_img):
        x1=[]
        y1=[]
        for i in range (match4_g+match3_g,match4_g+match3_g+match2_g):
            p1 = geo[j][con[i].p[j]].pnr
            if (p1>-1 and con[i].p[j] > -1):
                x1.append(pix[j][p1].x)
                y1.append(pix[j][p1].y)
        pairs_x.append(x1)
        pairs_y.append(y1)
    pairs.append(pairs_x)
    pairs.append(pairs_y)
#get unused -----------------------------------------


    unused_x=[]
    unused_y=[]
    
    for j in range (n_img):
        x1=[]
        y1=[]
        for i in range(num[j]):
            p1 = pix[j][i].tnr
            if p1 == -1 :
                x1.append(pix[j][i].x)
                y1.append(pix[j][i].y)
        unused_x.append(x1)
        unused_y.append(y1)
    unused.append(unused_x)
    unused.append(unused_y)

def py_get_from_calib(x,y):
    global x_calib,y_calib,ncal_points  
    cdef int i,j
    for i in range(n_img):
        x1=[]
        y1=[]
        for j in range(ncal_points[i]):
            x1.append(x_calib[i][j])
            y1.append(y_calib[i][j])
        x.append(x1)
        y.append(y1)

def py_get_from_sortgrid(x,y,pnr):
    global x_calib,y_calib,z_calib,ncal_points,pix  
    cdef int i,j
    for i in range(n_img):
        x1=[]
        y1=[]
        pnr1=[]
        for j in range(ncal_points[i]):
            if (z_calib[i][j]>=0):
                x1.append(pix[i][j].x)
                y1.append(pix[i][j].y)
                pnr1.append(z_calib[i][j])
            
        x.append(x1)
        y.append(y1)
        pnr.append(pnr1)
        
def py_get_from_orient(x1,y1,x2,y2):
    global orient_x1,orient_y1,orient_x2,orient_y2,orient_n

    cdef int i,j
    for i in range(n_img):
        x_1=[]
        y_1=[]
        x_2=[]
        y_2=[]
        for j in range(orient_n[i]+1):
            x_1.append(orient_x1[i][j])
            y_1.append(orient_y1[i][j])
            x_2.append(orient_x2[i][j])
            y_2.append(orient_y2[i][j])
            
        x1.append(x_1)
        y1.append(y_1)
        x2.append(x_2)
        y2.append(y_2)
        
def  py_sequence_init(dumbflag=0):
    sequence_proc_c(<int>dumbflag)

# set dumbell=1, if dumbflag=3, see jw_ptv.c
def py_sequence_loop(dumbell,i):
    sequence_proc_loop_c(<int>dumbell,<int>i)

def py_get_from_sequence_init():
    global seq_step_shake
    return seq_step_shake
    
def py_trackcorr_init():
    global lmax_track,ymin_track,ymax_track, seq_first, seq_last
    trackcorr_c_init()
    return lmax_track,ymin_track,ymax_track, seq_first, seq_last
    
def py_trackcorr_loop(step, lmax, Ymin, Ymax,display):
    global intx0_tr,intx1_tr,intx2_tr,inty0_tr,inty1_tr,inty2_tr,pnr1_tr,pnr2_tr,pnr3_tr,m1_tr
    trackcorr_c_loop(<int>step,<float>lmax, <float>Ymin, <float>Ymax, <int>display)
    cdef int i,j
    if display:
        intx0,intx1,intx2,inty0,inty1,inty2,pnr1,pnr2,pnr3=[],[],[],[],[],[],[],[],[]
        print m1_tr
        
        for i in range(n_img):
            intx0_t,intx1_t,intx2_t,inty0_t,inty1_t,inty2_t,pnr1_t,pnr2_t,pnr3_t=[],[],[],[],[],[],[],[],[]
            for j in range (m1_tr):
                intx0_t.append(intx0_tr[i][j])
                inty0_t.append(inty0_tr[i][j])
                intx1_t.append(intx1_tr[i][j])
                inty1_t.append(inty1_tr[i][j])
                intx2_t.append(intx2_tr[i][j])
                inty2_t.append(inty2_tr[i][j])
                if pnr1_tr[i][j]>-1:
                    pnr1_t.append(pnr1_tr[i][j])
                if pnr2_tr[i][j]>-1:
                    pnr2_t.append(pnr2_tr[i][j])
                if pnr3_tr[i][j]>-1:
                    pnr3_t.append(pnr3_tr[i][j])
            intx0.append(intx0_t)
            intx1.append(intx1_t)
            intx2.append(intx2_t)
            inty0.append(inty0_t)
            inty1.append(inty1_t)
            inty2.append(inty2_t)
            pnr1.append(pnr1_t)
            pnr2.append(pnr2_t)
            pnr3.append(pnr3_t)
        return intx0,intx1,intx2,inty0,inty1,inty2,pnr1,pnr2,pnr3,m1_tr
    return 0
    
    
def py_trackcorr_finish(step):
    trackcorr_c_finish(<int>step)
    
def py_trackback_c():
    trackback_c ()
    
def py_get_mark_track_c(i_img,h):
    global t4,imx,imy,zoom_x,zoom_y,zoom_f
    return t4[3][i_img][h].x, t4[3][i_img][h].y,t4[3][i_img][h].tnr,imx,imy,zoom_x[i_img],zoom_y[i_img],zoom_f[i_img]

def py_get_nt4(i_img):
    global nt4
    return  nt4[3][i_img]

def py_read_ascii_data(i_seq):
    read_ascii_data(i_seq)

def py_traject_loop(seq):
    global intx1_tr,intx2_tr,inty1_tr,inty2_tr,m1_tr
    trajectories_c(seq)
    intx1,intx2,inty1,inty2=[],[],[],[]
    for i in range(n_img):
        intx1_t,intx2_t,inty1_t,inty2_t=[],[],[],[]
        for j in range(m1_tr):
            intx1_t.append(intx1_tr[i][j])
            inty1_t.append(inty1_tr[i][j])
            intx2_t.append(intx2_tr[i][j])
            inty2_t.append(inty2_tr[i][j])
        intx1.append(intx1_t)
        inty1.append(inty1_t)
        intx2.append(intx2_t)
        inty2.append(inty2_t)
    return intx1,inty1,intx2,inty2,m1_tr
        
def py_ptv_set_dumbbell(dumbbell):
    global dumbbell_pyptv
    dumbbell_pyptv=<int>dumbbell
    
def py_right_click(coord_x,coord_y,n_image):
    global rclick_intx1,rclick_inty1,rclick_intx2,rclick_inty2, rclick_points_x1,rclick_points_y1,rclick_count,rclick_points_intx1, rclick_points_inty1
    x2_points,y2_points,x1,y1,x2,y2=[],[],[],[],[],[]
    r=mouse_proc_c (<int>coord_x, <int> coord_y, 3,<int>n_image)
    if r==-1:
        return -1,-1,-1,-1,-1,-1,-1,-1
    for i in range(n_img):
        x2_temp,y2_temp=[],[]
        for j in range(rclick_count[i]):
            x2_temp.append(rclick_points_x1[i][j])
            y2_temp.append(rclick_points_y1[i][j])
        x2_points.append(x2_temp)
        y2_points.append(y2_temp)
        x1.append(rclick_intx1[i])
        y1.append(rclick_inty1[i])
        x2.append(rclick_intx2[i])
        y2.append(rclick_inty2[i])
    return  x1,y1,x2,y2,x2_points,y2_points,rclick_points_intx1, rclick_points_inty1
            
def py_determination_proc_c(dumbbell):
    determination_proc_c (<int>dumbbell)

def py_rclick_delete(coord_x,coord_y,n_image):
    mouse_proc_c(<int>coord_x, <int> coord_y, 4,<int>n_image)

def py_get_pix_N(x,y,n_image):
    global pix,n_img
    cdef int i,j
    i=n_image
    x1=[]
    y1=[]
    for j in range(num[i]):
      x1.append(pix[i][j].x)
      y1.append(pix[i][j].y)
      x.append(x1)
      y.append(y1)
