package com.example.scannner_opencv_flutter_java;


import android.annotation.SuppressLint;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;

import androidx.annotation.NonNull;
import androidx.exifinterface.media.ExifInterface;

import org.opencv.android.OpenCVLoader;
import org.opencv.android.Utils;
import org.opencv.core.Core;
import org.opencv.core.CvType;
import org.opencv.core.Mat;
import org.opencv.core.MatOfByte;
import org.opencv.core.MatOfPoint;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.core.Rect;
import org.opencv.core.Scalar;
import org.opencv.core.Size;
import org.opencv.imgcodecs.Imgcodecs;
import org.opencv.imgproc.Imgproc;
import org.opencv.imgproc.Moments;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.security.cert.PolicyNode;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    byte[] byteArray;
    byte[] grayArray;
    byte[] originalArray;
    byte[] whiteBoardArray;
    @SuppressLint("WrongThread")
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(),"opencv").setMethodCallHandler((call, result) -> {


            if(call.method.equals("getCorners")) {
                if (OpenCVLoader.initDebug()) {
                    //Bitmap de entrada imagen original
                    Bitmap BInImage = BitmapFactory.decodeFile(call.argument("imagePath").toString());

                //Se instancia la clase points image
                //constructor Bitmap Image se pasa como parametro Bitmapde la Imagen
                    PointsImage Points =new PointsImage(BInImage);
                //Se obtiene la matriz de la imagen original
                    Mat MOrigImg=Points.GetMOriginalImg();

                //Se obtiene la matriz escala de grises de la imagen original
                    Mat grayImg=Points.GetMGrayImg(MOrigImg);
                //Se obtiene la matriz en blanco y negro
                    Mat bwImg=Points.GetMBlackWite(MOrigImg);
                
                //Se obtienen los contornos externos mediante el metodo canny se requiere como parametro la imagen en escala de grises y se retorna una matriz con los contornos
                    Mat cannyImg=Points.GetContour(MOrigImg);

                //Se buscan los contornos de acuerdo a los contornos obtenidos por canny
                    List<MatOfPoint> listcontours=Points.SearchContourns(bwImg);
                //Se obtiene el contorno mas grande
                    Points.GetLargerContour(grayImg);
                //Se afina la busqueda de contornos retornando las esquinas
                    MatOfPoint BestCorners=Points.RefineContours(listcontours);

                //Se realiza la busqueda del cuadrado a partir de las esquinas obtenidas del mejor contorno
                MatOfPoint CornersSquare=Points.SearchSquare(BestCorners);

                //Se pintan las equinas  sobre la imagen
                    Mat MOrigImgContours=Points.PaintCorners(BestCorners,grayImg);

                //TODO:Pendiente afinar la clasificación de contornos con algun metodo
                //Se clasifica la lista de contornos obtenidos y se obtiene la imagen original pintando los contornos obtenidos
                    //Mat MOrigImgContours = Points.ClassiFyContounrs(listcontours,MOrigImg);

                //Metodo usado para convertir una Matriz -> Bitmap-> bytearray
                    byte[] byteArray =Points.GetBytesImg(MOrigImgContours);
                    result.success(byteArray);




                /*
                    //Se obtiene el alto y ancho de la imagen
                int height = BInImage.getHeight();
                System.out.println(height);
                int width = BInImage.getWidth();
                System.out.println(width);
                    //Matriz de entrada imagen original
                    Mat MInImg=new Mat();
                    //Matriz de salida
                    Mat MOutImg=new Mat();
                    //Se pasa BitMap -> Matriz
                    Utils.bitmapToMat(BInImage,MInImg);

                    // Crear un kernel de tamaño 5x5 con todos los elementos iguales a 1
                    //Mat kernel = Mat.ones(new Size(5, 5), CvType.CV_8UC1);
                    //Aplicar la operación de cierre repetido para eliminar el texto del documento
                    //Imgproc.morphologyEx(MInImg, MInImg, Imgproc.MORPH_CLOSE, kernel, new Point(-1,-1), 1);


                    //Se convierte la imagen a scalade griese
                    Mat gray=new Mat();
                    Imgproc.cvtColor(MInImg,gray,Imgproc.COLOR_BGR2GRAY);

                    //Se aplica GausianBluer
                    //Mat gbluer=new Mat();
                    //Imgproc.GaussianBlur(gray,gbluer,new Size(3,3),0);
                    //gbluer.copyTo(gray);

                    //Se obtienen los contornos externos
                    Mat canny= new Mat();
                    Imgproc.Canny(gray,canny,10,150);
                    Mat dilateKer = Imgproc.getStructuringElement(Imgproc.MORPH_ELLIPSE, new Size(5, 5));
                    Imgproc.dilate(canny, canny, dilateKer);



                    //Encontrar los contornos
                    List<MatOfPoint> contours = new ArrayList<>();
                    Mat hierarchy = new Mat();
                    Imgproc.findContours(canny,contours,hierarchy,Imgproc.RETR_EXTERNAL,Imgproc.CHAIN_APPROX_SIMPLE);

                    //Se ordenan los conrtornos de acuerdo a su tamaño
                    Collections.sort(contours, (o1, o2) -> Double.compare(Imgproc.contourArea(o2), Imgproc.contourArea(o1)));

                    //Obtenemos el contorno mas grande
                    MatOfPoint Count=contours.get(0);
                    System.out.println(Imgproc.contourArea(Count));

                    //Se itera sobre todos los contornos encontrados comenzando por el contorno mas grande
                    for(MatOfPoint c : contours){
                        double AreaEachContour=Imgproc.contourArea(c);
                        //Se imprime el area de cada contorno
                        //System.out.println(AreaEachContour);
                        double epsilon = 0.01 * Imgproc.arcLength(new MatOfPoint2f(c.toArray()), true);
                        MatOfPoint2f corners2f = new MatOfPoint2f();
                        //Se obtienen los vertices
                        Imgproc.approxPolyDP(new MatOfPoint2f(c.toArray()), corners2f, epsilon, true);
                        //Se imprimen los vertices obetenidos
                        //System.out.println(corners2f.toList());

                            //Si el numero de vertices es igual a 4 sabemos que se trata de un rectangulo
                            MatOfPoint corners = new MatOfPoint(corners2f.toArray());
                            //System.out.println("nContornos"+corners.height());
                            //Si se tiene mas de 3 vertices muy seguramente es un cuadrado y si el area del elemento coincide con el del contoro mas grande
                            if (corners.size().height >= 3 && AreaEachContour == Imgproc.contourArea(Count)) {
                                //Linea azul sobre la imagen original
                                Imgproc.drawContours(MInImg, Arrays.asList(c), -1, new Scalar(0, 255, 255), 15);
                                //Linea amarilla sobre la imagen original
                                Imgproc.drawContours(MInImg, Arrays.asList(corners), -1, new Scalar(0, 255, 0), 5);

                                //Se pintan los vertices de interes
                                for (Point point: corners.toArray()){
                                    System.out.println(point);
                                    Imgproc.circle(MInImg,point, 15,new Scalar(255,0,0),15);
                                }
                                //Imgproc.circle(MInImg,corners.toArray()[0], 25,new Scalar(255,0,0),15);
                                //Imgproc.circle(MInImg,corners.toArray()[1], 25,new Scalar(255,0,0),15);
                                //Imgproc.circle(MInImg,corners.toArray()[2], 25,new Scalar(255,0,0),15);
                                //Imgproc.circle(MInImg,corners.toArray()[3], 25,new Scalar(255,0,0),15);

                            //    break;
                            }
                    }*/


                    //Matriz -> to MOutImg
                    //MInImg.copyTo(MOutImg);




                    // Crear un kernel de tamaño 5x5 con todos los elementos iguales a 1
                    //Mat kernel = Mat.ones(new Size(5, 5), CvType.CV_8UC1);
                    // Aplicar la operación de cierre repetido para eliminar el texto del documento
                    //Imgproc.morphologyEx(img, img, Imgproc.MORPH_CLOSE, kernel, new Point(-1,-1), 3);

                    /*
                    //Se aplica escala de grises a matriz
                    Mat gray = new Mat();
                    Imgproc.cvtColor(img, gray, Imgproc.COLOR_BGR2GRAY);

                    // Binarizar la imagen
                    Mat thresh = new Mat();
                    Imgproc.threshold(gray, thresh, 0, 255, Imgproc.THRESH_BINARY + Imgproc.THRESH_OTSU);

                    //img.copyTo(thresh); //imagen binarizada
                    thresh.copyTo(img);

                    //Mat gr=new Mat();
                    //Imgproc.GaussianBlur(img,img,new Size(5,5),0);
                    Mat canny=new Mat();
                    Imgproc.Canny(img,canny,10,150);
                     //Dilatar los bordes.
                    Mat kernel3 = Imgproc.getStructuringElement(Imgproc.MORPH_ELLIPSE, new Size(5, 5));
                    Imgproc.dilate(canny, canny, kernel3);

                    canny.copyTo(img);
                    */


                    /*
                    Mat con = new Mat(img.size(), img.type(), new Scalar(0, 0, 0));
                    List<MatOfPoint> contours = new ArrayList<>();
                    Mat hierarchy = new Mat();
                    Imgproc.findContours(img, contours, hierarchy, Imgproc.RETR_LIST, Imgproc.CHAIN_APPROX_NONE);
                    System.out.println(contours.size());


                    Collections.sort(contours, (o1, o2) -> Double.compare(Imgproc.contourArea(o2), Imgproc.contourArea(o1)));


                    Imgproc.drawContours(img, contours.subList(0, Math.min(contours.size(), 5)), -1, new Scalar(255, 255, 0), 5);
                    img.copyTo(img);

                    Mat conn=Mat.zeros(img.size(),img.type());
                    for(MatOfPoint c : contours){
                        // Approximate the contour.
                        double epsilon = 0.01 * Imgproc.arcLength(new MatOfPoint2f(c.toArray()), true);
                        MatOfPoint2f corners2f = new MatOfPoint2f();
                        Imgproc.approxPolyDP(new MatOfPoint2f(c.toArray()), corners2f, epsilon, true);
                        MatOfPoint corners = new MatOfPoint(corners2f.toArray());
                        if (corners.size().height == 4) {
                            break;
                        }
                        Imgproc.drawContours(img, Arrays.asList(c), -1, new Scalar(0, 255, 255), 3);
                        Imgproc.drawContours(img, Arrays.asList(corners), -1, new Scalar(0, 255, 0), 10);

                        // Sorting the corners and converting them to desired shape.
                                List<Point> cornersList = Arrays.asList(corners.toArray());
                        Collections.sort(cornersList, new Comparator<Point>() {
                            @Override
                            public int compare(Point o1, Point o2) {
                                return Double.compare(o1.x, o2.x);
                            }
                        });
                        corners = new MatOfPoint(cornersList.toArray(new Point[0]));

                        // Displaying the corners.
                        for (int i = 0; i < corners.toArray().length; i++) {
                            String character = String.valueOf((char) (65 + i));
                            Imgproc.putText(img, character, corners.toArray()[i], Core.FONT_HERSHEY_SIMPLEX, 1, new Scalar(255, 0, 0), 1, Core.LINE_AA, false);
                        }
                    }*/



                    //gray.copyTo(img);


                    /*
                    Mat img_8uc3 = new Mat();
                    if (img.channels() == 1) {
                        Imgproc.cvtColor(img, img_8uc3, Imgproc.COLOR_GRAY2BGR);
                    } else if (img.channels() == 4) {
                        Imgproc.cvtColor(img, img_8uc3, Imgproc.COLOR_RGBA2BGR);
                    } else {
                        img.copyTo(img_8uc3);
                    }*/






                    //Mat mask = new Mat(img.size(), CvType.CV_8UC1, new Scalar(0));
                    //Mat bgdModel = new Mat(1, 65, CvType.CV_64FC1, new Scalar(0));
                    //Mat fgdModel = new Mat(1, 65, CvType.CV_64FC1, new Scalar(0));
                    //Rect rect = new Rect(20, 20, img.cols() - 20, img.rows() - 20);
                    //Imgproc.grabCut(img_8uc3, mask, rect, bgdModel, fgdModel, 5, Imgproc.GC_INIT_WITH_RECT);
                    //Mat mask2 = new Mat();
                    //Core.compare(mask, new Scalar(2), mask2, Core.CMP_EQ);
                    //Core.compare(mask, new Scalar(0), mask2, Core.CMP_EQ);
                    //mask2.convertTo(mask2, CvType.CV_8UC1, 255);
                    //Core.multiply(img, mask2, img);


                    /*
                    // Encontrar contornos
                    List<MatOfPoint> contours = new ArrayList<>();
                    Mat hierarchy = new Mat();
                    Imgproc.findContours(thresh, contours, hierarchy, Imgproc.RETR_EXTERNAL, Imgproc.CHAIN_APPROX_SIMPLE);


                     //Colocar rectangulo en la imagen
                    // Obtener coordenadas de esquinas
                    Rect rect = Imgproc.boundingRect(contours.get(0));
                    Point topLeft = rect.tl();
                    Point bottomRight = rect.br();
                    Point topRight = new Point(bottomRight.x, topLeft.y);
                    Point bottomLeft = new Point(topLeft.x, bottomRight.y);
                    System.out.println(topLeft);
                    System.out.println(bottomRight);
                    System.out.println(topRight);
                    System.out.println(bottomLeft);

                    Point tpl=new Point(0,0);
                    Point bpr=new Point(1000,1000);


                    // Dibujar rectángulo en la imagen original
                    Imgproc.rectangle(img, tpl, bpr, new Scalar(255, 255, 0), 15);*/


                    //Bitmap de salida Matriz -> Bitmap
                    //Bitmap OutImg = Bitmap.createBitmap(MOutImg.cols(), MOutImg.rows(), Bitmap.Config.ARGB_8888);

                    //Se conviert matriz a bitmap
                    //Utils.matToBitmap(MOutImg,OutImg);

                    //!RESCALE IMAGE
                    //bitmap=Bitmap.createScaledBitmap(bmp,2480,3508,true);


                    //!PREPARING BITMAP TO SEND IN BYTEARRAY ON FORMAT JPGE
                    //ByteArrayOutputStream stream=new ByteArrayOutputStream();
                    //OutImg.compress(Bitmap.CompressFormat.JPEG,100,stream);
                    //byte[] byteArray=stream.toByteArray();

                    //Metodo usado para convertir una Matriz -> Bitmap-> bytearray
                    //byte[] byteArray =Points.GetBytesImg(MOutImg);
                    //result.success(byteArray);
                }
            }

            if (call.method.equals("convertToGray")){
                System.out.println("convertToGray");
                byte[] imageBytes=call.argument("imageBytes");

                //Se orienta la imagen ya que en ocaciones no se reconocen los metadatos EXIF
                //Rebibe byte[] -> return Bitmap
                Bitmap bitmap=orientImage(imageBytes);


                //!GET WIDTH AND HEIGHT TO IMAGE
                int width=bitmap.getWidth();
                int height=bitmap.getHeight();
                //!GET POINTS OF CROP IMAGE
                double tl_x=call.argument("tl_x");
                double tl_y=call.argument("tl_y");
                double tr_x=call.argument("tr_x");
                double tr_y=call.argument("tr_y");
                double bl_x=call.argument("bl_x");
                double bl_y=call.argument("bl_y");
                double br_x=call.argument("br_x");
                double br_y=call.argument("br_y");

                if(OpenCVLoader.initDebug()) {
                    Mat mat=new Mat();
                Utils.bitmapToMat(bitmap,mat);
                Imgproc.cvtColor(mat,mat,Imgproc.COLOR_BGR2GRAY);
                Imgproc.GaussianBlur(mat,mat,new Size(5,5),0);
                Mat src_mat=new Mat(4,1, CvType.CV_32FC2);
                Mat dst_mat=new Mat(4,1,CvType.CV_32FC2);


                src_mat.put(0,0,tl_x,tl_y,tr_x,tr_y,bl_x,bl_y,br_x,br_y);
                dst_mat.put(0,0,0.0,0.0,width,0.0, 0.0,height,width,height);
                Mat perspectiveTransform=Imgproc.getPerspectiveTransform(src_mat, dst_mat);

                Imgproc.warpPerspective(mat, mat, perspectiveTransform, new Size(width,height));

                Imgproc.adaptiveThreshold(mat,mat,255,Imgproc.ADAPTIVE_THRESH_MEAN_C,Imgproc.THRESH_BINARY,401,14);

                Mat blurred=new Mat();
                Imgproc.GaussianBlur(mat,blurred,new Size(5,5),0);
                Mat result1=new Mat();
                Core.addWeighted(blurred,0.5,mat,0.5,1,result1);


                Utils.matToBitmap(result1,bitmap);

                //!RESCALE IMAGE
                bitmap=Bitmap.createScaledBitmap(bitmap,2480,3508,true);


                //!PREPARING BITMAP TO SEND IN BYTEARRAY ON FORMAT JPGE
                ByteArrayOutputStream stream=new ByteArrayOutputStream();
                bitmap.compress(Bitmap.CompressFormat.JPEG,100,stream);
                byte[] byteArray=stream.toByteArray();
                result.success(byteArray);
                }
            }
            /*
            if(call.method.equals("convertToGray")){
                System.out.println("convertToGray");
                Bitmap bitmap= BitmapFactory.decodeFile(call.argument("filePath").toString());
                int height=bitmap.getHeight();
                int width=bitmap.getWidth();
                double tl_x=call.argument("tl_x");
                double tl_y=call.argument("tl_y");
                double tr_x=call.argument("tr_x");
                double tr_y=call.argument("tr_y");
                double bl_x=call.argument("bl_x");
                double bl_y=call.argument("bl_y");
                double br_x=call.argument("br_x");
                double br_y=call.argument("br_y");
                System.out.println(tl_x);
                if(OpenCVLoader.initDebug()) {
                    System.out.println("Opencv Working");
                    Mat mat=new Mat();
                    Utils.bitmapToMat(bitmap,mat);

                    Imgproc.cvtColor(mat,mat,Imgproc.COLOR_BGR2GRAY);
                    Imgproc.GaussianBlur(mat,mat,new Size(5,5),0);
                    Mat src_mat=new Mat(4,1, CvType.CV_32FC2);
                    Mat dst_mat=new Mat(4,1,CvType.CV_32FC2);
                    src_mat.put(0,0,tl_x,tl_y,tr_x,tr_y,bl_x,bl_y,br_x,br_y);
                    dst_mat.put(0,0,0.0,0.0,width,0.0, 0.0,height,width,height);
                    Mat perspectiveTransform=Imgproc.getPerspectiveTransform(src_mat, dst_mat);

                    Imgproc.warpPerspective(mat, mat, perspectiveTransform, new Size(width,height));

                    Imgproc.adaptiveThreshold(mat,mat,255,Imgproc.ADAPTIVE_THRESH_MEAN_C,Imgproc.THRESH_BINARY,401,14);
                    Mat blurred=new Mat();
                    Imgproc.GaussianBlur(mat,blurred,new Size(5,5),0);
                    Mat result1=new Mat();
                    Core.addWeighted(blurred,0.5,mat,0.5,1,result1);

                    Utils.matToBitmap(result1,bitmap);
                    bitmap=Bitmap.createScaledBitmap(bitmap,2480,3508,true);
                    ByteArrayOutputStream stream=new ByteArrayOutputStream();
                    bitmap.compress(Bitmap.CompressFormat.JPEG,100,stream);
                    byte[] byteArray=stream.toByteArray();
                    result.success(byteArray);

                }
            }*/
            if(call.method.equals("original")){
                Bitmap bitmap= BitmapFactory.decodeFile(call.argument("filePath").toString());
                int height=bitmap.getHeight();
                int width=bitmap.getWidth();
                double tl_x=call.argument("tl_x");
                double tl_y=call.argument("tl_y");
                double tr_x=call.argument("tr_x");
                double tr_y=call.argument("tr_y");
                double bl_x=call.argument("bl_x");
                double bl_y=call.argument("bl_y");
                double br_x=call.argument("br_x");
                double br_y=call.argument("br_y");
                OriginalThread originalThread=new OriginalThread( bitmap,height,width,tl_x,tl_y,tr_x,tr_y,bl_x,bl_y,br_x,br_y);
                originalThread.start();
                result.success("");
            }
            if(call.method.equals("gray")){
                Bitmap bitmap= BitmapFactory.decodeFile(call.argument("filePath").toString());
                int height=bitmap.getHeight();
                int width=bitmap.getWidth();
                double tl_x=call.argument("tl_x");
                double tl_y=call.argument("tl_y");
                double tr_x=call.argument("tr_x");
                double tr_y=call.argument("tr_y");
                double bl_x=call.argument("bl_x");
                double bl_y=call.argument("bl_y");
                double br_x=call.argument("br_x");
                double br_y=call.argument("br_y");
                GrayThread grayThread=new GrayThread(
                        bitmap,height,width,tl_x,tl_y,tr_x,tr_y,bl_x,bl_y,br_x,br_y);
                grayThread.start();
                result.success("");
            }
            if(call.method.equals("whiteboard")){
                Bitmap bitmap= BitmapFactory.decodeFile(call.argument("filePath").toString());
                int height=bitmap.getHeight();
                int width=bitmap.getWidth();
                double tl_x=call.argument("tl_x");
                double tl_y=call.argument("tl_y");
                double tr_x=call.argument("tr_x");
                double tr_y=call.argument("tr_y");
                double bl_x=call.argument("bl_x");
                double bl_y=call.argument("bl_y");
                double br_x=call.argument("br_x");
                double br_y=call.argument("br_y");
                WhiteBoardThread whiteBoardThread=new WhiteBoardThread( bitmap,height,width,tl_x,tl_y,tr_x,tr_y,bl_x,bl_y,br_x,br_y);
                whiteBoardThread.start();
            }
            if(call.method.equals("rotate")){
                byte[] byteArray=call.argument("bytes");
                RotateThread rotateThread=new RotateThread(byteArray);
                rotateThread.start();
                result.success(byteArray);
            }
            if(call.method.equals("rotateCompleted")){
                result.success(byteArray);
            }
            if(call.method.equals("grayCompleted")){
                result.success(grayArray);
            }
            if(call.method.equals("originalCompleted")) {
                result.success(originalArray);
            }
            if(call.method.equals("whiteboardCompleted")){
                result.success(whiteBoardArray);
            }
        });
    }

    //Se ajusta la imagen acorde a su orientacion de sus metadatos EXIF
    private Bitmap orientImage(byte[] imageBytes){
        //Bytes de image a orientar se convierten BitMap
        Bitmap bitmap= BitmapFactory.decodeByteArray(imageBytes,0,imageBytes.length);
        int orientation;

        try {
            ExifInterface exif = new ExifInterface(new ByteArrayInputStream(imageBytes));
            orientation=exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        //Se obtiene el angulo de orientación
        int angle=getRotationAngle(orientation);
        //Se crea matriz de orienrtación
        Matrix matrix=new Matrix();
        //Se crea una matriz de orientación en base al angulo obtenido
        matrix.postRotate(angle);
        //Se retorna el bitmap de la imagen orientada a partir de la matriz de orientación matrix
        return Bitmap.createBitmap(bitmap,0,0,bitmap.getWidth(),bitmap.getHeight(),matrix,true);
    }
    //Se obtiene el angulo de la imagen a orientar de acuerdo a los metadatos EXIF para la posterior orientación
    private int getRotationAngle(int orientation) {
        int angle;
        switch (orientation) {
            case ExifInterface.ORIENTATION_ROTATE_90:
                angle = 90;
                break;
            case ExifInterface.ORIENTATION_ROTATE_180:
                angle = 180;
                break;
            case ExifInterface.ORIENTATION_ROTATE_270:
                angle = 270;
                break;
            default:
                angle = 0;
        }
        return angle;
    }

    class RotateThread extends  Thread{

        RotateThread(byte[] bytes){
            byteArray=bytes;
        }
        @Override
        public void run() {
            System.out.println("started");
            Matrix matrix=new Matrix();
            matrix.postRotate(90);
            Bitmap bitmap = BitmapFactory.decodeByteArray(byteArray, 0, byteArray.length);
            Bitmap rotatedBitmap = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);
            ByteArrayOutputStream stream=new ByteArrayOutputStream();
            rotatedBitmap.compress(Bitmap.CompressFormat.JPEG,100,stream);
            byteArray=stream.toByteArray();

        }
    }
    class GrayThread extends Thread{
        Bitmap bitmap;
        int height,width;
        double tl_x,tl_y,tr_x,tr_y,bl_x,bl_y,br_x,br_y;
        GrayThread(Bitmap bitmap,int height, int width,double tl_x, double tl_y,double tr_x,double tr_y,double bl_x,double bl_y,double br_x,double br_y){
            this.bitmap=bitmap;
            this.height=height;
            this.width=width;
            this.tl_x=tl_x;
            this.tl_y=tl_y;
            this.tr_x=tr_x;
            this.tr_y=tr_y;
            this.bl_x=bl_x;
            this.bl_y=bl_y;
            this.br_x=br_x;
            this.br_y=br_y;
        }
        @Override
        public void run() {
            System.out.println("GRay started");
            Mat mat=new Mat();
            Utils.bitmapToMat(bitmap,mat);
            Mat src_mat=new Mat(4,1, CvType.CV_32FC2);
            Mat dst_mat=new Mat(4,1,CvType.CV_32FC2);
            src_mat.put(0,0,tl_x,tl_y,tr_x,tr_y,bl_x,bl_y,br_x,br_y);
            dst_mat.put(0,0,0.0,0.0,width,0.0, 0.0,height,width,height);
            Mat perspectiveTransform=Imgproc.getPerspectiveTransform(src_mat, dst_mat);

            Imgproc.warpPerspective(mat, mat, perspectiveTransform, new Size(width,height));
            Imgproc.cvtColor(mat,mat,Imgproc.COLOR_BGR2GRAY);
            Utils.matToBitmap(mat,bitmap);
            bitmap=Bitmap.createScaledBitmap(bitmap,2480,3508,true);
            ByteArrayOutputStream stream=new ByteArrayOutputStream();
            bitmap.compress(Bitmap.CompressFormat.JPEG,100,stream);
            byte[] byteArray=stream.toByteArray();
            grayArray=byteArray;
        }
    }
    class OriginalThread extends Thread{
        Bitmap bitmap;
        int height,width;
        double tl_x,tl_y,tr_x,tr_y,bl_x,bl_y,br_x,br_y;
        OriginalThread(Bitmap bitmap,int height, int width,double tl_x, double tl_y,double tr_x,double tr_y,double bl_x,double bl_y,double br_x,double br_y){
            this.bitmap=bitmap;
            this.height=height;
            this.width=width;
            this.tl_x=tl_x;
            this.tl_y=tl_y;
            this.tr_x=tr_x;
            this.tr_y=tr_y;
            this.bl_x=bl_x;
            this.bl_y=bl_y;
            this.br_x=br_x;
            this.br_y=br_y;
        }
        @Override
        public void run() {
            System.out.println("original started");
            Mat mat=new Mat();
            Utils.bitmapToMat(bitmap,mat);
            Mat src_mat=new Mat(4,1, CvType.CV_32FC2);
            Mat dst_mat=new Mat(4,1,CvType.CV_32FC2);
            src_mat.put(0,0,tl_x,tl_y,tr_x,tr_y,bl_x,bl_y,br_x,br_y);
            dst_mat.put(0,0,0.0,0.0,width,0.0, 0.0,height,width,height);
            Mat perspectiveTransform=Imgproc.getPerspectiveTransform(src_mat, dst_mat);

            Imgproc.warpPerspective(mat, mat, perspectiveTransform, new Size(width,height));
            Utils.matToBitmap(mat,bitmap);
            bitmap=Bitmap.createScaledBitmap(bitmap,2480,3508,true);
            ByteArrayOutputStream stream=new ByteArrayOutputStream();
            bitmap.compress(Bitmap.CompressFormat.JPEG,100,stream);
            byte[] byteArray=stream.toByteArray();
            originalArray=byteArray;
        }
    }
    class WhiteBoardThread extends Thread{
        Bitmap bitmap;
        int height,width;
        double tl_x,tl_y,tr_x,tr_y,bl_x,bl_y,br_x,br_y;
        WhiteBoardThread(Bitmap bitmap,int height, int width,double tl_x, double tl_y,double tr_x,double tr_y,double bl_x,double bl_y,double br_x,double br_y){
            this.bitmap=bitmap;
            this.height=height;
            this.width=width;
            this.tl_x=tl_x;
            this.tl_y=tl_y;
            this.tr_x=tr_x;
            this.tr_y=tr_y;
            this.bl_x=bl_x;
            this.bl_y=bl_y;
            this.br_x=br_x;
            this.br_y=br_y;
        }
        @Override
        public void run() {
            System.out.println("whiteboard started");
            Mat mat=new Mat();
            Utils.bitmapToMat(bitmap,mat);

            Imgproc.cvtColor(mat,mat,Imgproc.COLOR_BGR2GRAY);
            Imgproc.GaussianBlur(mat,mat,new Size(5,5),0);
            Mat src_mat=new Mat(4,1, CvType.CV_32FC2);
            Mat dst_mat=new Mat(4,1,CvType.CV_32FC2);
            src_mat.put(0,0,tl_x,tl_y,tr_x,tr_y,bl_x,bl_y,br_x,br_y);
            dst_mat.put(0,0,0.0,0.0,width,0.0, 0.0,height,width,height);
            Mat perspectiveTransform=Imgproc.getPerspectiveTransform(src_mat, dst_mat);

            Imgproc.warpPerspective(mat, mat, perspectiveTransform, new Size(width,height));

            Imgproc.adaptiveThreshold(mat,mat,255,Imgproc.ADAPTIVE_THRESH_MEAN_C,Imgproc.THRESH_BINARY,401,14);
            Mat blurred=new Mat();
            Imgproc.GaussianBlur(mat,blurred,new Size(5,5),0);
            Mat result1=new Mat();
            Core.addWeighted(blurred,0.5,mat,0.5,1,result1);

            Utils.matToBitmap(result1,bitmap);
            bitmap=Bitmap.createScaledBitmap(bitmap,2480,3508,true);
            ByteArrayOutputStream stream=new ByteArrayOutputStream();
            bitmap.compress(Bitmap.CompressFormat.JPEG,100,stream);
            byte[] byteArray=stream.toByteArray();
            whiteBoardArray=byteArray;
        }
    }
}
