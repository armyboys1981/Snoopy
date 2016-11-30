#import "ViewController.h"
#import "Device.h"
#import "ScanLAN.h"
#import "Timer.h"

@interface ViewController () <NSURLSessionDelegate, NSURLSessionDataDelegate>

@property (nonatomic) CFAbsoluteTime startTime;
@property (nonatomic) CFAbsoluteTime stopTime;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *connctedDevices;
@property ScanLAN *lanScanner;
@property NSMutableDictionary *dict;
@property NSString *theSpeed;
@property CGFloat speed;
@property SimplePing *sp;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UIBarButtonItem *refreshBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(startScanningLAN)];
    self.navigationItem.rightBarButtonItem = refreshBarButton;
}

- (void)viewDidAppear:(BOOL)animated {
    [self startScanningLAN];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.lanScanner stopScan];
    [self.lanScanner getUpnpDiscovery];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startScanningLAN {
    [self.lanScanner stopScan];
    self.lanScanner = [[ScanLAN alloc] initWithDelegate:self];
    self.connctedDevices = [[NSMutableArray alloc] init];
    [self.lanScanner startScan];
    [self.lanScanner getUpnpDiscovery];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.connctedDevices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //add subclass for table view cell with button in it 
    
    Device *device = [self.connctedDevices objectAtIndex:indexPath.row];
    cell.textLabel.text = device.name;
    cell.detailTextLabel.text = device.address;
    
    return cell;
}

- (IBAction)BtnClicked:(id)sender
{
    __block BOOL connection = TRUE;
    __block long bytesreceived;
    __block double totalSpeed;
    Timer *timer = [[Timer alloc] init];
    NSMutableArray *speedArray = [[NSMutableArray alloc] initWithCapacity:100];
    NSMutableArray *bytesArray = [[NSMutableArray alloc] initWithCapacity:100];
    NSString *strImgURLAsString = @"http://srollins.cs.usfca.edu/images/sami_purple.png";
    [strImgURLAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *imgURL = [NSURL URLWithString:strImgURLAsString];
    
    
    // Do some work
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:imgURL] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        for (int i = 0; i < 5; i++) {
            [timer startTimer];
            if (!connectionError) {
                connection = TRUE;
                UIImage *img = [[UIImage alloc] initWithData:data];
                NSData *imgdata = UIImagePNGRepresentation(img);
                bytesreceived = imgdata.length;
                NSLog(@"SUCCESS! @%@", img);
            } else {
                connection = FALSE;
                NSLog(@"%@",connectionError);
                NSLog(@"\n111- CONNECTION IS FALSE BREAK BREAK BREAK\n");
            }
            [timer stopTimer];
            double msgSpeed = [timer timeElapsedInMilliseconds];
            NSLog(@"\nSPEED IS: %f\n", msgSpeed);
            [speedArray addObject:[NSNumber numberWithDouble:msgSpeed]];
            [bytesArray addObject:[NSNumber numberWithLong:bytesreceived]];
            i++;

        }
        NSLog(@"SPEED ARRAY: %@",  speedArray);
        NSLog(@"Byte ARRAY: %@",  bytesArray);
        NSLog(@"HERE is the connection: %s", connection ? "TRUE" : "FALSE");

        
        for (NSNumber *speed in speedArray) {
            double kSpeed = [speed doubleValue];
            totalSpeed += kSpeed;
        }
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (connection) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
            Device *device = [self.connctedDevices objectAtIndex:indexPath.row];
            NSString *test = device.name;
            NSString *speedMsg =[NSString stringWithFormat:@"Current speed is %f%@", totalSpeed, @" mbps"];
            NSString *diagIp = [NSString stringWithFormat:@"Diagnostics for %@", test];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:diagIp
                                                            message:speedMsg
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            [alert show];
        } else {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
            Device *device = [self.connctedDevices objectAtIndex:indexPath.row];
            NSString *test = device.name;
            NSString *diagIp = [NSString stringWithFormat:@"Diagnostics for %@", test];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:diagIp
                                                            message:@"TEST"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            [alert show];
        }
    });
}



/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


  //Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
  //Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
  //Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */
#pragma mark LAN Scanner delegate method
- (void)scanLANDidFindNewAdrress:(NSString *)address havingHostName:(NSString *)hostName {
    NSLog(@"found  %@", address);
    Device *device = [[Device alloc] init];
    device.name = hostName;
    device.address = address;
    [self.connctedDevices addObject:device];
    [self.tableView reloadData];
}

- (void)scanLANDidFinishScanning {
    NSLog(@"Scan finished");

    self.dict = [[NSMutableDictionary alloc] initWithCapacity:50];
    
    [self.dict setObject:self.connctedDevices forKey:@"Connected Devices"];
    
    //having data leaks with dictionary and saving to storage file
    @try{
        NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:self.dict];
        [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:@"test"];
        NSLog(@"DICTIONARY IS: @%@", self.dict);
        NSLog(@"DICTIONARY IS: @%@", dataSave);
        // [[NSUserDefaults standardUserDefaults] synchronize];
    } @catch (NSException* exception) {
        NSLog(@"Got exception: %@    Reason: %@", exception.name, exception.reason);
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Scan Finished" message:[NSString stringWithFormat:@"Number of devices connected to the Local Area Network : %d", self.connctedDevices.count] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}
@end
