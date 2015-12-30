#!/bin/sh
#This script gets image file name from targetdir,
#and check the existence of image in sourcedir,
#if there is an image, then it creates large/med thumb.
#If there is not an image, then it records the missing image name in missing.txt.


#raw images
sourcedir='/Users/DY/Documents/Works/rawimage/'

#pre-existing original images(maybe from server)
targetdir='/Users/DY/Documents/Works/newimage/original/'
#large thumb images(maybe from server)
largethumbdir='/Users/DY/Documents/Works/newimage/thumb_large/'
#med thumb images(maybe from server)
medthumbdir='/Users/DY/Documents/Works/newimage/thumb_med/'

echo $targetdir

cd $targetdir
for i in *"IMG_"*; do
    pichash=${i%%IMG_*}
    echo "====$pichash"
    picname=IMG_${i##*IMG_}
    echo "====$picname"
    
    if cd $sourcedir;test -e "$picname"
        then
            
            #get image height and width from detail
            h=$( mdls "$targetdir/$i"|grep kMDItemPixelHeight|tail -n1|cut -d= -f2 )
            w=$( mdls "$targetdir/$i" | grep kMDItemPixelWidth | tail -n1 | cut -d= -f2 )
            
            echo "====found $picname, lets replace it and save back to original dir"
            mv $targetdir/$i $targetdir/bk_$i
            cp $sourcedir/$picname $targetdir/$pichash$picname
            sips -Z 960 $targetdir/$pichash$picname
            
            echo "====then create new large thumb"
            mv $largethumbdir/$i $largethumbdir/bk_$i
            cp $sourcedir/$picname $largethumbdir/$pichash$picname
            
            if [ "$h" -gt "$w" ]
                then
                    echo "==this is portraite image"
                    sips -z 565 765 $largethumbdir/$pichash$picname
                    sips --cropToHeightWidth 565 285 $largethumbdir/$pichash$picname
                else
                    echo "==this is landscape image"
                    sips -Z 565 $largethumbdir/$pichash$picname
                    sips --cropToHeightWidth 285 565 $largethumbdir/$pichash$picname
            fi
            
            echo "====then create new med thumb"
            mv $medthumbdir/$i $medthumbdir/bk_$i
            cp $sourcedir/$picname $medthumbdir/$pichash$picname
            
            if [ "$h" -gt "$w" ]
                then
                    echo "==this is portraite image"
                    sips -z 480 640 $medthumbdir/$pichash$picname
                    sips --cropToHeightWidth 480 270 $medthumbdir/$pichash$picname
                else
                    echo "==this is landscape image"
                    sips -Z 480 $medthumbdir/$pichash$picname
                    sips --cropToHeightWidth 270 480 $medthumbdir/$pichash$picname
            fi
            
        else
            echo "====Cant find $i"
            echo $i >> missing.txt
    fi
done