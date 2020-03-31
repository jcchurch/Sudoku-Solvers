extern crate rand;
 
use std::io;
use std::collections::LinkedList;
use rand::Rng;
 
const WIDTH: usize = 9;
const SIZE: usize = WIDTH * WIDTH;
const SECTORS: [usize; SIZE] = [ 0, 0, 0, 1, 1, 1, 2, 2, 2,
                                 0, 0, 0, 1, 1, 1, 2, 2, 2,
                                 0, 0, 0, 1, 1, 1, 2, 2, 2,
                                 3, 3, 3, 4, 4, 4, 5, 5, 5,
                                 3, 3, 3, 4, 4, 4, 5, 5, 5,
                                 3, 3, 3, 4, 4, 4, 5, 5, 5,
                                 6, 6, 6, 7, 7, 7, 8, 8, 8,
                                 6, 6, 6, 7, 7, 7, 8, 8, 8,
                                 6, 6, 6, 7, 7, 7, 8, 8, 8];
 
fn print_grid(grid: &[usize; SIZE]) {
    for i in 0..WIDTH {
        for j in 0..WIDTH {
            print!("{} ", grid[i * WIDTH + j])
        }
        println!("");
    }
}
 
fn read_grid(original: &mut [usize; SIZE]) {
    let mut index: usize = 0;
    for _ in 0..WIDTH {
        let mut row = String::new();
        io::stdin().read_line(&mut row).expect("Failed to read a number.");
        let elements: Vec<&str> = row.split(' ').collect();
 
        for element in elements.iter() {
            let value: usize = element.trim().parse().expect("Number not found.");
            original[index] = value;
            index += 1;
        }
    }
}
 
fn copy_array(from: &[usize; SIZE], to: &mut [usize; SIZE]) {
    for i in 0..SIZE {
        to[i] = from[i];
    }
}
 
fn retry_solution(mut grid: &mut [usize; SIZE], original: &[usize; SIZE]) {
    let mut current_score: usize = 1;
    while current_score > 0 {
        copy_array(&original, &mut grid);
        populate_grid(&mut grid, &original);
        current_score = solve(&mut grid, &original);
    }
}
 
fn solve(grid: &mut [usize; SIZE], original: &[usize; SIZE]) -> usize {
    let mut current_score: usize = score(grid);
    let mut getting_nowhere: usize = 0;
 
    while current_score > 0 && getting_nowhere < 100 {
        let swap_sector = rand::thread_rng().gen_range(0, WIDTH);
        let mut unblocked = get_sector_open_locations(swap_sector, original);
        shuffle_list(&mut unblocked);    
 
        if unblocked.len() > 1 {
            let index_first = unblocked.pop_front().unwrap();
            let index_second = unblocked.pop_front().unwrap();
 
            let temporary = grid[ index_first ];
            grid[ index_first ] = grid[ index_second ];
            grid[ index_second ] = temporary;
       
            let next_score = score(grid);
 
            if next_score > current_score {
                let temporary = grid[ index_first ];
                grid[ index_first ] = grid[ index_second ];
                grid[ index_second ] = temporary;
                getting_nowhere += 1;
            }
            else {
                if next_score == current_score {
                    getting_nowhere += 1;
                }
                else {
                    getting_nowhere = 0;
                }
 
                current_score = next_score;
                //println!("{} {}", current_score, getting_nowhere);
            }
        }
    }
 
    current_score
}
 
fn populate_grid(mut grid: &mut [usize; SIZE], original: &[usize; SIZE]) {
    for i in 0..WIDTH {
        populate_sector(i, &mut grid, &original);
    }
}
 
fn populate_sector(swap_sector: usize, grid: &mut [usize; SIZE], original: &[usize; SIZE]) {
    let unblocked = get_sector_open_locations(swap_sector, original);
    let mut unused = get_sector_unused_values(swap_sector, original);
    shuffle_list(&mut unused);    
 
    for index in unblocked.iter() {
        grid[ *index ] = unused.pop_front().unwrap();
    }
}
 
fn get_sector_open_locations(swap_sector: usize, original: &[usize; SIZE]) -> LinkedList<usize> {
    let mut list: LinkedList<usize> = LinkedList::new();
 
    for i in 0..SIZE {
        if SECTORS[i] == swap_sector && original[i] == 0 {
            list.push_back(i);
        }
    }
 
    list
}
 
fn get_sector_unused_values(swap_sector: usize, original: &[usize; SIZE]) -> LinkedList<usize> {
    let mut unused: LinkedList<usize> = LinkedList::new();
    let mut checkarray: [usize; 10] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
 
    for i in 0..SIZE {
        if SECTORS[i] == swap_sector && original[i] != 0 {
            checkarray[ original[i] ] = 0;
        }
    }
 
    for element in checkarray.iter() {
        if *element > 0 {
            unused.push_back( *element );
        }
    }
 
    unused
}
 
fn shuffle_list(list: &mut LinkedList<usize>) {
    let mut permutation = LinkedList::<usize>::new();
 
    while list.len() > 0 {
        let index = rand::thread_rng().gen_range(0, list.len());
        let mut splitted = list.split_off(index);
        permutation.push_back(*splitted.front().unwrap());
        splitted.pop_front();
        list.append(&mut splitted);
    }
 
    for element in permutation.iter() {
        list.push_back(*element);
    }
}
 
fn score(grid: &[usize; SIZE]) -> usize {
    let mut score: usize = 0;
 
    for i in 0..WIDTH {
        let mut rowcheckarray: [usize; 10] = [1; 10];
        let mut colcheckarray: [usize; 10] = [1; 10];
 
        for j in 0..WIDTH {
            if rowcheckarray[ grid[i * WIDTH + j] ] == 1 {
                rowcheckarray[ grid[i * WIDTH + j] ] = 0;
            }
            else {
                score += 1;
            }
 
            if colcheckarray[ grid[j * WIDTH + i] ] == 1 {
                colcheckarray[ grid[j * WIDTH + i] ] = 0;
            }
            else {
                score += 1;
            }
        }
 
    }
 
    score
}
 
fn main() {
    let mut original: [usize; SIZE] = [0; SIZE];
    let mut grid: [usize; SIZE] = [0; SIZE];
    read_grid(&mut original);
    retry_solution(&mut grid, &original);
    print_grid(&grid);
}
