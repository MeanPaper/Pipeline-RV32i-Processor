
int main(){
    int one_range_min = -10000;
    int one_range_max = 10000;
    int two_range_min = -10000;
    int two_range_max = 10000;


    int input_one, input_two;
    int product;
    
    // looping and testing
    for(input_one = one_range_min; input_one < one_range_max; ++input_one){
        for(input_two = two_range_min; input_two < two_range_max; ++input_two){
            product = input_one * input_two;
        }

    }


    return 0;
}