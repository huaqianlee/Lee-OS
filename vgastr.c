

void _strwrite(char *string)
{
    char *p_strdst = (char *)(0xb8000); // Point to start of display address
    while (*string)
    {
        *p_strdst = *string++;
        p_strdst += 2; // Skip the color part of char mode display
    }
    return;
}

void printf(char *fmt, ...)
{
    _strwrite(fmt);
    return;
}
