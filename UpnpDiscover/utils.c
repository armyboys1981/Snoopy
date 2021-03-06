//
// Created by Jacob Tarnow on 9/27/16.
//
#include <stdlib.h>
#include <string.h>

#include "utils.h"

/*
 * *******************************************************************
 * Function: str_vector_init()
 * Purpose: Given a pointer to *vector, initialize it for further use
 * Returns: 0 on success
 * *******************************************************************
 */
int str_vector_init(struct str_vector *vector)
{
    vector->str_array = NULL;
    vector->str_count = 0;

    return(0);
}

/*
 * *******************************************************************
 * Function: str_vector_add()
 * Purpose: Given a pointer to string *str, add it to *vector
 * Returns: 0 on success, -1 otherwise
 * *******************************************************************
 */
int str_vector_add(struct str_vector *vector, char *str)
{
    if ( (vector->str_array = (char **)realloc(vector->str_array,
                                               (vector->str_count + 1) * sizeof(char *))) == NULL )
    {
        return(-1);
    }

    if ( (vector->str_array[vector->str_count++] = strdup(str)) == NULL )
    {
        return(-1);
    }

    return(0);
}

/*
 * *******************************************************************
 * Function: str_vector_search()
 * Purpose: Given a pointer to string *search_str, see if it is
 *          in *vector
 * Returns: TRUE if *search_str is in *vector, FALSE otherwise
 * *******************************************************************
 */
int str_vector_search(struct str_vector *vector, char *search_str)
{
    int i;

    for (i = 0; i < vector->str_count; i++)
    {
        if ( strcmp(vector->str_array[i], search_str) == 0 )
            return(TRUE);
    }

    return(FALSE);
}

/*
 * *******************************************************************
 * Function: str_vector_free()
 * Purpose: Given a pointer to *vector, free memory associated with
 *          its strings
 * Returns: 0 on success
 * *******************************************************************
 */
int str_vector_free(struct str_vector *vector)
{
    int i;

    for ( i = 0; i < vector->str_count; i++ )
    {
        free(vector->str_array[i]);
    }

    free(vector->str_array);
    vector->str_count = 0;

    return(0);
}