-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Feb 15, 2025 at 06:52 PM
-- Server version: 10.6.17-MariaDB
-- PHP Version: 7.4.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `yasupada_trip`
--

-- --------------------------------------------------------

--
-- Table structure for table `groups`
--

CREATE TABLE `groups` (
  `id` int(11) NOT NULL,
  `owner_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `groups`
--

INSERT INTO `groups` (`id`, `owner_id`, `name`, `description`, `created_at`) VALUES
(1, 1, 'Trip North Thai', 'Short term trip', '2024-11-29 09:34:16'),
(2, 1, '1234', 'nana', '2024-12-04 14:06:25'),
(3, 1, 'Robinson', '25 op', '2024-12-04 14:07:48'),
(4, 1, 'Robim', '2565', '2024-12-04 14:08:23'),
(5, 1, 'Robin', 'lost', '2024-12-04 14:09:06'),
(6, 1, '123', '', '2024-12-04 14:13:27'),
(7, 3, 'pattaya', '3 day', '2024-12-04 16:21:28'),
(8, 1, 'nanBack to home', 'nan 6-10', '2024-12-05 03:38:49'),
(9, 1, 'Back to home ', 'Nan 6-10', '2024-12-05 03:39:13'),
(10, 1, 'sssssssss', 'wwwwwww', '2024-12-05 04:33:13'),
(11, 1, 'ssss', 'sssss', '2024-12-05 04:36:12'),
(12, 1, 'naqn', '123', '2024-12-05 04:57:00'),
(13, 5, 'KU81', 'pattaya', '2024-12-06 08:19:44'),
(14, 6, 'KU82', 'pattaya 3 day', '2024-12-06 10:08:39'),
(15, 7, 'KU81', 'gg', '2024-12-09 17:25:22'),
(16, 8, 'KU81', 'pattaya', '2024-12-10 11:06:33');

-- --------------------------------------------------------

--
-- Table structure for table `group_members`
--

CREATE TABLE `group_members` (
  `group_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `joined_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `group_members`
--

INSERT INTO `group_members` (`group_id`, `user_id`, `joined_at`) VALUES
(1, 1, '2024-12-04 17:15:35'),
(1, 2, '2024-12-04 17:17:03'),
(1, 3, '2024-12-04 03:31:33'),
(1, 4, '2024-12-06 08:41:01'),
(7, 1, '2024-12-04 17:10:36'),
(7, 4, '2024-12-09 17:26:47'),
(10, 1, '2024-12-05 04:33:13'),
(11, 1, '2024-12-05 04:36:12'),
(12, 1, '2024-12-05 04:57:00'),
(12, 3, '2024-12-05 04:57:42'),
(13, 4, '2024-12-06 08:20:14'),
(13, 5, '2024-12-06 08:19:44'),
(14, 4, '2024-12-06 10:09:02'),
(14, 6, '2024-12-06 10:08:39'),
(15, 7, '2024-12-09 17:25:22'),
(16, 4, '2024-12-10 11:06:50'),
(16, 8, '2024-12-10 11:06:33');

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `id` int(11) NOT NULL,
  `group_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `messages`
--

INSERT INTO `messages` (`id`, `group_id`, `user_id`, `message`, `created_at`) VALUES
(1, 1, 1, '0:hi, need to go to trip', '2024-11-29 09:34:43'),
(2, 1, 1, '0:test message', '2024-11-29 09:35:09'),
(3, 1, 1, '0:test', '2024-11-29 09:46:51'),
(5, 1, 1, '0:this trip awesom', '2024-11-30 07:33:11'),
(7, 1, 1, '0:ok', '2024-11-30 07:35:13'),
(8, 1, 1, '0:okay', '2024-11-30 07:35:17'),
(12, 1, 1, '1:1:North Trip on to GO', '2024-12-01 12:18:32'),
(13, 1, 3, '0:123456', '2024-12-01 12:44:50'),
(14, 1, 3, '0:test', '2024-12-01 12:44:52'),
(15, 1, 1, '1:2:NaNland', '2024-12-05 03:41:17'),
(16, 12, 1, '1:1:North Trip on to G', '2024-12-05 04:59:44'),
(17, 13, 5, '0:hi', '2024-12-06 08:19:59'),
(18, 13, 4, '0:hi', '2024-12-06 08:21:10'),
(19, 13, 4, '1:4:pattaya', '2024-12-06 08:21:28'),
(20, 1, 1, '1:4:pattaya', '2024-12-06 08:39:01'),
(21, 1, 1, '1:4:pattaya', '2024-12-06 08:40:45'),
(22, 14, 6, '0:hi', '2024-12-06 10:08:48'),
(23, 14, 6, '1:6:pattaya', '2024-12-06 10:10:49'),
(24, 15, 7, '1:12:pattaya', '2024-12-09 17:25:30'),
(25, 7, 1, '1:12:pattaya', '2024-12-09 17:26:52'),
(26, 7, 4, '1:5:bangkok', '2024-12-09 18:23:02'),
(27, 7, 4, '1:7:bangkok trip', '2024-12-09 18:23:03'),
(28, 16, 8, '0:hi', '2024-12-10 11:06:40'),
(29, 16, 8, '1:13:Pattaya', '2024-12-10 11:07:03');

-- --------------------------------------------------------

--
-- Table structure for table `trips`
--

CREATE TABLE `trips` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `destination` varchar(255) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `status` enum('active','closed') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `latitude` varchar(100) NOT NULL,
  `longitude` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `trips`
--

INSERT INTO `trips` (`id`, `user_id`, `name`, `destination`, `start_date`, `end_date`, `status`, `created_at`, `latitude`, `longitude`) VALUES
(5, 4, 'bangkok', '3 day budget 1500 go to zoo 500 and eat buffet 299 hotel 300', '2025-01-01', '2025-01-04', 'active', '2024-12-06 08:57:26', '13.803140531122192', '100.5499241331862'),
(6, 6, 'pattaya', '3 day budget 1500 swin cafe ', '2024-12-14', '2024-12-16', 'active', '2024-12-06 10:07:55', '12.936890616952919', '100.882655043189'),
(7, 4, 'bangkok trip', '3 day budget 2000  Go to shopping and go to Cafe eat streetfood', '2024-12-15', '2024-12-17', 'active', '2024-12-09 10:58:26', '', ''),
(8, 1, 't', 't', '2024-12-09', '2024-12-11', 'active', '2024-12-09 12:43:22', '', ''),
(9, 1, 'xxxxx', 'cccccc', '2024-12-09', '2024-12-10', 'active', '2024-12-09 16:45:00', '13.908710649977175', '100.50685090437159'),
(10, 1, 'sdfsdf', 'sdsdfsdf', '2024-12-09', '2024-12-10', 'active', '2024-12-09 16:49:03', '13.755237927234706', '100.5000352741063'),
(11, 3, 'sdfsdfsdf', 'sdfsdfs', '2024-12-10', '2024-12-11', 'active', '2024-12-09 16:59:00', '13.753244054804698', '100.50142351538916'),
(12, 7, 'pattaya', '3 day hotel 1000 travel 500 food 500 ', '2025-01-07', '2025-01-09', 'active', '2024-12-09 17:24:57', '12.936185330568343', '100.88588403881093'),
(13, 8, 'Pattaya', 'Go for 3 days food cost 1000 accommodation cost 1500 activities 1500', '2025-01-11', '2025-01-13', 'active', '2024-12-10 11:06:12', '12.93522828619918', '100.88160656757644');

-- --------------------------------------------------------

--
-- Table structure for table `trip_events`
--

CREATE TABLE `trip_events` (
  `id` int(11) NOT NULL,
  `trip_id` int(11) NOT NULL,
  `event_name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `event_date` date NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `trip_expenses`
--

CREATE TABLE `trip_expenses` (
  `id` int(11) NOT NULL,
  `trip_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `trip_participants`
--

CREATE TABLE `trip_participants` (
  `id` int(11) NOT NULL,
  `trip_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `start_date` date DEFAULT current_timestamp(),
  `end_date` date DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `trip_participants`
--

INSERT INTO `trip_participants` (`id`, `trip_id`, `user_id`, `start_date`, `end_date`) VALUES
(2, 1, 2, '2024-12-03', '2024-12-04'),
(3, 1, 3, '2024-12-03', '2024-12-09'),
(6, 2, 1, '2024-12-06', '2024-12-10'),
(7, 4, 4, '2024-12-21', '2024-12-23'),
(8, 4, 5, '2024-12-21', '2024-12-23'),
(9, 6, 4, '2024-12-21', '2024-12-23'),
(10, 8, 1, '2024-12-09', '2024-12-11'),
(11, 9, 1, '2024-12-09', '2024-12-10'),
(12, 10, 1, '2024-12-10', '2024-12-11'),
(13, 11, 3, '2024-12-09', '2024-12-09'),
(15, 12, 4, '2025-01-11', '2025-01-13'),
(16, 5, 1, '2025-01-11', '2025-01-13'),
(17, 7, 1, '2025-01-07', '2025-01-09'),
(18, 13, 8, '2024-12-10', '2024-12-10'),
(19, 13, 4, '2025-01-18', '2025-01-20');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `password`, `created_at`) VALUES
(1, 'test2', 'test2@gmail.com', '$2y$10$JF5kZXWj.nkZjjQIllv4yOwuTKfPVFE5drhjFto9PQKaeaKydaFvW', '2024-11-29 09:13:29'),
(2, 'test1', 'test1@gmail.com', '$2y$10$DA1qfw4TePXEzRQQkZohDOHRAL.Xwe3./45.dTpKfAziX54zMVwv.', '2024-12-01 04:35:35'),
(3, 'test3', 'test3@gmail.com', '$2y$10$JH8EuAD5nUmq4RsCTKey8eyF5msaxo1.ia7p.3TLx1wG4gZORUQ/y', '2024-12-01 12:17:28'),
(4, 'patanin1', 'patanin1@gmail.com', '$2y$10$fuk.YriWzWPdcb2C487GpuEdtOYbX8jmUCZsw2j16B3jIKpIeHZdm', '2024-12-06 04:53:11'),
(5, 'natchapon1', 'natchapon1@gmail.com', '$2y$10$/P.fPlKMlrL1y5ojpoRgd.RFNvQtgOEyE0rWlGfaCHbXMNF2NkHXm', '2024-12-06 08:10:42'),
(6, 'natchapon2', 'natchapon2@gamil.com', '$2y$10$.6gMlpVwFxAATpl1buvPGuuQYYvM8oIZ37/543WEMa5vz3XGC9gc.', '2024-12-06 10:06:31'),
(7, 'boontu1', 'boontu1@gmail.com', '$2y$10$WxJCN3.z94ayzv1fF3W8yuIDNQRTMMznHCVK1JPaQorDj3BeBotLW', '2024-12-09 17:22:15'),
(8, 'natchapon', 'natchapon@gmail.com', '$2y$10$3weEAItisSivrgBMNXC9yO3EaD7k1kG3.XgckFIUOXdckr3M9jH4i', '2024-12-10 11:02:10');

-- --------------------------------------------------------

--
-- Table structure for table `user_profiles`
--

CREATE TABLE `user_profiles` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `first_name` varchar(50) DEFAULT '',
  `last_name` varchar(50) DEFAULT '',
  `phone` varchar(20) DEFAULT '',
  `address` varchar(255) DEFAULT '',
  `profile_picture` varchar(255) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `user_profiles`
--

INSERT INTO `user_profiles` (`id`, `user_id`, `first_name`, `last_name`, `phone`, `address`, `profile_picture`) VALUES
(1, 1, 'Welcome', 'comwel', '12345678', 'address', ''),
(2, 2, '', '', '', '', ''),
(3, 3, 'test3', '3', '093333333', '33/333', ''),
(4, 4, 'patanin', '', '0912422222', '22/222', ''),
(5, 5, '', '', '', '', ''),
(6, 6, '', '', '', '', ''),
(7, 7, '', '', '', '', ''),
(8, 8, '', '', '', '', '');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `groups`
--
ALTER TABLE `groups`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `group_members`
--
ALTER TABLE `group_members`
  ADD PRIMARY KEY (`group_id`,`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `group_id` (`group_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `trips`
--
ALTER TABLE `trips`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `trip_events`
--
ALTER TABLE `trip_events`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `trip_expenses`
--
ALTER TABLE `trip_expenses`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `trip_participants`
--
ALTER TABLE `trip_participants`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `groups`
--
ALTER TABLE `groups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT for table `trips`
--
ALTER TABLE `trips`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `trip_events`
--
ALTER TABLE `trip_events`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `trip_expenses`
--
ALTER TABLE `trip_expenses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `trip_participants`
--
ALTER TABLE `trip_participants`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `user_profiles`
--
ALTER TABLE `user_profiles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
