for file in ../../dataset/large/*/
do
  folder=$(basename $file)
    cp ../../dataset/large/$folder/$folder.mtx ../../dataset/large/$folder/$folder.edgelist
    sed '/^%/ d' ../../dataset/large/$folder/$folder.edgelist > ../../dataset/large/$folder/$folder.edgelist2
    sed '1d' ../../dataset/large/$folder/$folder.edgelist2 > ../../dataset/large/$folder/$folder.edgelist3
    sed 's/ /\t/g' ../../dataset/large/$folder/$folder.edgelist3 > ../../dataset/large/$folder/$folder.edgelist
    rm ../../dataset/large/$folder/$folder.edgelist2
    rm ../../dataset/large/$folder/$folder.edgelist3
done
